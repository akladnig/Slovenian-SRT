class TimestampCalculator {
  int parseTimestamp(String timestamp) {
    final parts = timestamp.split(':');
    if (parts.length != 2) {
      throw FormatException('Invalid timestamp format: $timestamp');
    }

    final minutes = int.parse(parts[0]);
    final seconds = int.parse(parts[1]);

    return minutes * 60 * 1000 + seconds * 1000;
  }

  String formatTimestamp(int milliseconds) {
    final hours = milliseconds ~/ 3600000;
    final minutes = (milliseconds % 3600000) ~/ 60000;
    final seconds = (milliseconds % 60000) ~/ 1000;
    final millis = milliseconds % 1000;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')},'
        '${millis.toString().padLeft(3, '0')}';
  }

  List<TimedSentence> calculateTimings(
    List<String> sentences,
    List<int> lineTimestamps,
    int totalDuration,
  ) {
    if (sentences.isEmpty) return [];

    final result = <TimedSentence>[];
    final totalTime = totalDuration.toDouble();

    for (int i = 0; i < sentences.length; i++) {
      final startMs = (i / sentences.length * totalTime).round();
      final endMs = ((i + 1) / sentences.length * totalTime).round();

      result.add(
        TimedSentence(
          text: sentences[i],
          startMs: startMs,
          endMs: endMs,
        ),
      );
    }

    return result;
  }
}

class TimedSentence {
  final String text;
  final int startMs;
  final int endMs;

  TimedSentence({
    required this.text,
    required this.startMs,
    required this.endMs,
  });
}
