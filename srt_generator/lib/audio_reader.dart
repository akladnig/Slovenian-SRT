import 'dart:io';

class AudioReader {
  int getDuration(String mp3Path) {
    final file = File(mp3Path);
    if (!file.existsSync()) {
      throw FileSystemException('Audio file not found', mp3Path);
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
        mp3Path,
      ],
    );

    if (result.exitCode != 0) {
      throw Exception('Unable to read audio duration: ${result.stderr}');
    }

    final seconds = double.parse(result.stdout.toString().trim());
    return (seconds * 1000).round();
  }
}
