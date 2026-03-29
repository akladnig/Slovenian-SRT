class MarkdownParser {
  static final _timestampRegex = RegExp(r'^(\d{2}):(\d{2})\s*-\s*(.*)$');

  List<ParsedLine> parseLines(List<String> lines) {
    final result = <ParsedLine>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final match = _timestampRegex.firstMatch(trimmed);
      if (match == null) continue;

      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      final text = match.group(3)!;

      result.add(
        ParsedLine(
          timestampMs: minutes * 60 * 1000 + seconds * 1000,
          text: text,
        ),
      );
    }

    return result;
  }

  List<String> processAndSplitLines(List<ParsedLine> lines) {
    final sentences = <Sentence>[];

    for (int i = 0; i < lines.length; i++) {
      final current = lines[i];
      final next = i + 1 < lines.length ? lines[i + 1] : null;

      String text = current.text;

      bool shouldJoin = next != null && !_endsWithSentenceTerminator(text);

      if (shouldJoin) {
        text = '$text ${next.text}';
        i++;
      }

      final splitSentences = _splitByPunctuation(text);

      int startTime = current.timestampMs;
      for (int j = 0; j < splitSentences.length; j++) {
        final sentence = splitSentences[j];
        final endTime = next != null && j == splitSentences.length - 1
            ? next.timestampMs
            : startTime + _estimateDuration(sentence);

        sentences.add(
          Sentence(text: sentence, startMs: startTime, endMs: endTime),
        );
        startTime = endTime;
      }
    }

    return sentences.map((s) => s.text).toList();
  }

  bool _endsWithSentenceTerminator(String text) {
    final trimmed = text.trim();
    return trimmed.endsWith('.') ||
        trimmed.endsWith('!') ||
        trimmed.endsWith('?');
  }

  List<String> _splitByPunctuation(String text) {
    final result = <String>[];
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      buffer.write(char);

      if (char == '.' || char == '!' || char == '?') {
        final segment = buffer.toString().trim();
        final stripped = _stripLeadingDash(segment);
        if (stripped.isNotEmpty) {
          result.add(stripped);
        }
        buffer.clear();
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

  int _estimateDuration(String text) {
    final words = text.split(RegExp(r'\s+')).length;
    return words * 150;
  }
}

class ParsedLine {
  final int timestampMs;
  final String text;

  ParsedLine({required this.timestampMs, required this.text});
}

class Sentence {
  final String text;
  final int startMs;
  final int endMs;

  Sentence({required this.text, required this.startMs, required this.endMs});
}
