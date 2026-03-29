import 'timestamp_calculator.dart';

class SrtFormatter {
  final TimestampCalculator _timestampCalculator = TimestampCalculator();

  String format(List<TimedSentence> sentences) {
    final buffer = StringBuffer();

    for (int i = 0; i < sentences.length; i++) {
      final sentence = sentences[i];

      buffer.writeln(i + 1);
      buffer.write(_timestampCalculator.formatTimestamp(sentence.startMs));
      buffer.write(' --> ');
      buffer.writeln(_timestampCalculator.formatTimestamp(sentence.endMs));
      buffer.writeln(sentence.text);
      buffer.writeln();
    }

    return buffer.toString();
  }
}
