import 'dart:io';
import 'package:meta/meta.dart';
import 'audio_reader.dart';
import 'markdown_parser.dart';
import 'timestamp_calculator.dart';
import 'srt_formatter.dart';
import 'video_audio_extractor.dart';

class SrtGenerator {
  final AudioReader _audioReader = AudioReader();
  final MarkdownParser _markdownParser = MarkdownParser();
  final SrtFormatter _srtFormatter = SrtFormatter();
  final VideoAudioExtractor _videoAudioExtractor = VideoAudioExtractor();

  String generate(String basePath) {
    final mp3Path = '$basePath.mp3';
    final m4aPath = '$basePath.m4a';
    final movPath = '$basePath.mov';
    final mdPath = '$basePath.md';
    final srtPath = '$basePath.srt';

    final audioPath = _resolveAudioPath(mp3Path, m4aPath, movPath);

    final mdFile = File(mdPath);
    if (!mdFile.existsSync()) {
      throw FileSystemException('Transcript file not found: $mdPath', mdPath);
    }

    final totalDuration = _audioReader.getDuration(audioPath);
    final mdLines = mdFile.readAsLinesSync();
    final parsedLines = _markdownParser.parseLines(mdLines);

    final timedSentences = calculateTimings(parsedLines, totalDuration);
    final srtContent = _srtFormatter.format(timedSentences);

    File(srtPath).writeAsStringSync(srtContent);

    return srtPath;
  }

  String _resolveAudioPath(String mp3Path, String m4aPath, String movPath) {
    final mp3File = File(mp3Path);
    final m4aFile = File(m4aPath);
    final movFile = File(movPath);

    final mp3Exists = mp3File.existsSync();
    final m4aExists = m4aFile.existsSync();
    final movExists = movFile.existsSync();

    if (!mp3Exists && !m4aExists && !movExists) {
      throw FileSystemException(
        'Audio file not found: $mp3Path, $m4aPath, or $movPath',
        mp3Path,
      );
    }

    if (movExists) {
      final movModified = movFile.lastModifiedSync();
      String? existingAudioPath;
      String? existingAudioExtension;

      if (mp3Exists) {
        existingAudioPath = mp3Path;
        existingAudioExtension = 'mp3';
      } else if (m4aExists) {
        existingAudioPath = m4aPath;
        existingAudioExtension = 'm4a';
      }

      if (existingAudioPath != null) {
        final existingModified = File(existingAudioPath).lastModifiedSync();
        if (movModified.isAfter(existingModified)) {
          _videoAudioExtractor.extractAudio(movPath, m4aPath);
          if (existingAudioExtension == 'mp3') {
            mp3File.deleteSync();
          }
          return m4aPath;
        }
        return existingAudioPath;
      } else {
        _videoAudioExtractor.extractAudio(movPath, m4aPath);
        return m4aPath;
      }
    }

    if (mp3Exists) {
      return mp3Path;
    }

    return m4aPath;
  }

  @visibleForTesting
  List<TimedSentence> calculateTimings(
    List<ParsedLine> parsedLines,
    int totalDuration,
  ) {
    if (parsedLines.isEmpty) return [];

    final result = <TimedSentence>[];

    int i = 0;
    while (i < parsedLines.length) {
      final current = parsedLines[i];
      String text = current.text;
      int lineStartMs = current.timestampMs;

      int joinedUntilIdx = i;
      int nextIdx = i + 1;
      while (nextIdx < parsedLines.length &&
          !endsWithSentenceTerminator(parsedLines[joinedUntilIdx].text) &&
          !containsHeaderTag(parsedLines[joinedUntilIdx].text)) {
        text = '$text ${parsedLines[nextIdx].text}';
        joinedUntilIdx = nextIdx;
        nextIdx++;
      }

      int lineEndMs;
      if (joinedUntilIdx + 1 < parsedLines.length) {
        lineEndMs = parsedLines[joinedUntilIdx + 1].timestampMs;
      } else {
        lineEndMs = totalDuration;
      }
      int lineDuration = lineEndMs - lineStartMs;
      if (lineDuration < 0) lineDuration = 0;

      final sentences = splitByPunctuation(text);
      if (sentences.isEmpty) continue;

      final totalChars = sentences.fold<int>(0, (sum, s) => sum + s.length);
      if (totalChars == 0) continue;

      int accumulatedTime = 0;
      for (final sentence in sentences) {
        final charCount = sentence.length;
        final sentenceDurationMs = (lineDuration * charCount / totalChars)
            .round();

        result.add(
          TimedSentence(
            text: sentence,
            startMs: lineStartMs + accumulatedTime,
            endMs: lineStartMs + accumulatedTime + sentenceDurationMs,
          ),
        );

        accumulatedTime += sentenceDurationMs;
      }

      i = nextIdx;
    }

    return result;
  }

  @visibleForTesting
  bool endsWithSentenceTerminator(String text) {
    final trimmed = text.trim();
    return trimmed.endsWith('.') ||
        trimmed.endsWith('!') ||
        trimmed.endsWith('?');
  }

  @visibleForTesting
  bool containsHeaderTag(String text) {
    return RegExp(r'<h[1-6]', caseSensitive: false).hasMatch(text);
  }

  @visibleForTesting
  List<String> splitByPunctuation(String text) {
    final result = <String>[];
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      buffer.write(char);

      if (char == '.' || char == '!' || char == '?') {
        final nextChar = i + 1 < text.length ? text[i + 1] : '';
        final hasMorePunctuation =
            nextChar == '.' || nextChar == '!' || nextChar == '?';

        if (!hasMorePunctuation) {
          final segment = buffer.toString().trim();
          final stripped = stripLeadingDash(segment);
          if (stripped.isNotEmpty) {
            result.add(stripped);
          }
          buffer.clear();
        }
      }
    }

    final remaining = buffer.toString().trim();
    if (remaining.isNotEmpty) {
      final stripped = stripLeadingDash(remaining);
      if (stripped.isNotEmpty) {
        result.add(stripped);
      }
    }

    return result;
  }

  @visibleForTesting
  String stripLeadingDash(String text) {
    final trimmed = text.trim();
    if (trimmed.startsWith('-')) {
      return trimmed.substring(1).trim();
    }
    return trimmed;
  }
}
