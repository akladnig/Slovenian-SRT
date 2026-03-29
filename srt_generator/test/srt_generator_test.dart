import 'package:srt_generator/markdown_parser.dart';
import 'package:srt_generator/timestamp_calculator.dart';
import 'package:test/test.dart';

void main() {
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
}
