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
}

class ParsedLine {
  final int timestampMs;
  final String text;

  ParsedLine({required this.timestampMs, required this.text});
}
