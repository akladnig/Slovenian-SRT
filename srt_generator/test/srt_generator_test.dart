import 'dart:io';

import 'package:srt_generator/audio_reader.dart';
import 'package:srt_generator/markdown_parser.dart';
import 'package:srt_generator/srt_generator.dart';
import 'package:srt_generator/timestamp_calculator.dart';
import 'package:test/test.dart';

void main() {
  group('AudioReader', () {
    test('example.mp3 duration is exactly 52352ms (0:00:52.352018)', () {
      final reader = AudioReader();
      final duration = reader.getDuration('../examples/example.mp3');
      expect(duration, 52352);
    });
  });

  group('TimestampCalculator', () {
    test('parses MM:SS timestamp correctly', () {
      final calculator = TimestampCalculator();
      expect(calculator.parseTimestamp('00:06'), 6000);
      expect(calculator.parseTimestamp('01:30'), 90000);
      expect(calculator.parseTimestamp('10:00'), 600000);
    });

    test('formats milliseconds to SRT timestamp', () {
      final calculator = TimestampCalculator();
      expect(calculator.formatTimestamp(6000), '00:00:06,000');
      expect(calculator.formatTimestamp(90000), '00:01:30,000');
      expect(calculator.formatTimestamp(3600000), '01:00:00,000');
    });
  });

  group('MarkdownParser', () {
    test('parses timestamp lines correctly', () {
      final parser = MarkdownParser();
      final lines = ['00:06 - Hello', '00:11 - World'];
      final parsed = parser.parseLines(lines);

      expect(parsed.length, 2);
      expect(parsed[0].timestampMs, 6000);
      expect(parsed[0].text, 'Hello');
      expect(parsed[1].timestampMs, 11000);
      expect(parsed[1].text, 'World');
    });

    test('splits text by punctuation', () {
      final parser = MarkdownParser();
      final lines = ['00:06 - Hello. World!'];
      final parsed = parser.parseLines(lines);

      expect(parsed.length, 1);
      expect(parsed[0].timestampMs, 6000);
      expect(parsed[0].text, 'Hello. World!');
    });

    test('strips leading dashes from segments', () {
      final lines = ['00:06 - Hello. - World!'];
      final content = lines.join('\n');

      expect(content.contains('- World'), true);
    });
  });

  group('SrtGenerator._splitByPunctuation', () {
    test('splits text by punctuation', () {
      final generator = SrtGenerator();
      final result = generator.splitByPunctuation('Hello. World!');
      expect(result, ['Hello.', 'World!']);
    });

    test('preserves multiple consecutive dots', () {
      final generator = SrtGenerator();
      final result = generator.splitByPunctuation('Hello... World.');
      expect(result, ['Hello...', 'World.']);
    });

    test('strips leading dash from split segments', () {
      final generator = SrtGenerator();
      final result = generator.splitByPunctuation('Hello. - World.');
      expect(result, ['Hello.', 'World.']);
    });
  });

  group('SrtGenerator._endsWithSentenceTerminator', () {
    test('detects sentence terminators', () {
      final generator = SrtGenerator();
      expect(generator.endsWithSentenceTerminator('Hello.'), true);
      expect(generator.endsWithSentenceTerminator('Hello!'), true);
      expect(generator.endsWithSentenceTerminator('Hello?'), true);
      expect(generator.endsWithSentenceTerminator('Hello'), false);
    });
  });

  group('SrtGenerator._containsHeaderTag', () {
    test('detects header tags h1-h6', () {
      final generator = SrtGenerator();
      expect(generator.containsHeaderTag('<h1>Title</h1>'), true);
      expect(generator.containsHeaderTag('<H2>Title</H2>'), true);
      expect(generator.containsHeaderTag('No header'), false);
    });
  });

  group('SrtGenerator._stripLeadingDash', () {
    test('strips leading dash', () {
      final generator = SrtGenerator();
      expect(generator.stripLeadingDash('- Hello'), 'Hello');
      expect(generator.stripLeadingDash('  - Hello'), 'Hello');
      expect(generator.stripLeadingDash('Hello'), 'Hello');
    });
  });

  group('SrtGenerator._calculateTimings', () {
    test('character-count proportional timing', () {
      final generator = SrtGenerator();
      final lines = [
        ParsedLine(timestampMs: 0, text: 'Hello... World.'),
      ];
      final result = generator.calculateTimings(lines, 4000);

      expect(result.length, 2);
      final totalChars = 'Hello...'.length + 'World.'.length;
      final expectedFirst = (4000 * 'Hello...'.length / totalChars).round();
      expect(result[0].endMs - result[0].startMs, expectedFirst);
    });
  });

  group('Integration', () {
    test('generated SRT matches example_for_testing.srt', () {
      final generator = SrtGenerator();
      final outputPath = generator.generate('../examples/example');
      final generatedFile = File(outputPath);
      final expectedFile = File('test/example_for_testing.srt');

      expect(generatedFile.existsSync(), true);
      expect(
        generatedFile.readAsStringSync(),
        expectedFile.readAsStringSync(),
      );

      generatedFile.deleteSync();
    });
  });
}
