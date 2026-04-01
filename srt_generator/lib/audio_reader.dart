import 'dart:io';

class AudioReader {
  int getDuration(String audioPath) {
    final file = File(audioPath);
    if (!file.existsSync()) {
      throw FileSystemException('Audio file not found', audioPath);
    }

    final result = Process.runSync(
      'ffprobe',
      [
        '-v',
        'error',
        '-show_entries',
        'format=duration',
        '-of',
        'csv=p=0',
        audioPath,
      ],
    );

    if (result.exitCode != 0) {
      throw Exception('Unable to read audio duration: ${result.stderr}');
    }

    final seconds = double.parse(result.stdout.toString().trim());
    return (seconds * 1000).round();
  }
}
