import 'dart:io';

class VideoAudioExtractor {
  void extractAudio(String movPath, String m4aPath) {
    final movFile = File(movPath);
    if (!movFile.existsSync()) {
      throw FileSystemException('Video file not found', movPath);
    }

    final result = Process.runSync(
      'ffmpeg',
      [
        '-i',
        movPath,
        '-vn',
        '-acodec',
        'copy',
        '-y',
        m4aPath,
      ],
    );

    if (result.exitCode != 0) {
      throw Exception('Audio extraction failed: ${result.stderr}');
    }

    final m4aFile = File(m4aPath);
    if (!m4aFile.existsSync()) {
      throw Exception('Audio extraction did not create output file');
    }
  }
}
