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

    for (int i = 0; i < parsedLines.length; i++) {
      final current = parsedLines[i];
      final next = i + 1 < parsedLines.length ? parsedLines[i + 1] : null;

      String text = current.text;

      if (next != null &&
          !_endsWithSentenceTerminator(text) &&
          !_containsHeaderTag(text)) {
        text = '$text ${next.text}';
        i++;
      }

      final sentences = _splitByPunctuation(text);

      if (sentences.isEmpty) continue;

      final lineStartMs = current.timestampMs;
      final lineEndMs = next?.timestampMs ?? totalDuration;
      final lineDuration = lineEndMs - lineStartMs;
      final sentenceDuration = (lineDuration / sentences.length).round();

      for (int j = 0; j < sentences.length; j++) {
        final startMs = lineStartMs + (j * sentenceDuration);
        final endMs = j == sentences.length - 1
            ? lineEndMs
            : lineStartMs + ((j + 1) * sentenceDuration);

        result.add(
          TimedSentence(
            text: sentences[j],
            startMs: startMs,
            endMs: endMs,
          ),
        );
      }
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
