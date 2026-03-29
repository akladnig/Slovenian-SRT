import 'dart:io';
import 'audio_reader.dart';
import 'markdown_parser.dart';
import 'timestamp_calculator.dart';
import 'srt_formatter.dart';

class SrtGenerator {
  final AudioReader _audioReader = AudioReader();
  final MarkdownParser _markdownParser = MarkdownParser();
  final SrtFormatter _srtFormatter = SrtFormatter();

  String generate(String basePath) {
    final mp3Path = '$basePath.mp3';
    final mdPath = '$basePath.md';
    final srtPath = '$basePath.srt';

    final mp3File = File(mp3Path);
    if (!mp3File.existsSync()) {
      throw FileSystemException('Audio file not found', mp3Path);
    }

    final mdFile = File(mdPath);
    if (!mdFile.existsSync()) {
      throw FileSystemException('Transcript file not found', mdPath);
    }

    final totalDuration = _audioReader.getDuration(mp3Path);
    final mdLines = mdFile.readAsLinesSync();
    final parsedLines = _markdownParser.parseLines(mdLines);

    final timedSentences = _calculateTimings(parsedLines, totalDuration);
    final srtContent = _srtFormatter.format(timedSentences);

    File(srtPath).writeAsStringSync(srtContent);

    return srtPath;
  }

  List<TimedSentence> _calculateTimings(
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
          !_endsWithSentenceTerminator(parsedLines[joinedUntilIdx].text) &&
          !_containsHeaderTag(parsedLines[joinedUntilIdx].text)) {
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

      final sentences = _splitByPunctuation(text);
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

  bool _endsWithSentenceTerminator(String text) {
    final trimmed = text.trim();
    return trimmed.endsWith('.') ||
        trimmed.endsWith('!') ||
        trimmed.endsWith('?');
  }

  bool _containsHeaderTag(String text) {
    return RegExp(r'<h[1-6]', caseSensitive: false).hasMatch(text);
  }

  List<String> _splitByPunctuation(String text) {
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
          final stripped = _stripLeadingDash(segment);
          if (stripped.isNotEmpty) {
            result.add(stripped);
          }
          buffer.clear();
        }
      }
    }

    final remaining = buffer.toString().trim();
    if (remaining.isNotEmpty) {
      final stripped = _stripLeadingDash(remaining);
      if (stripped.isNotEmpty) {
        result.add(stripped);
      }
    }

    return result;
  }

  String _stripLeadingDash(String text) {
    final trimmed = text.trim();
    if (trimmed.startsWith('-')) {
      return trimmed.substring(1).trim();
    }
    return trimmed;
  }
}
