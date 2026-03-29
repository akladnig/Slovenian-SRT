import 'dart:io';
import 'package:mp3_info/mp3_info.dart';

class AudioReader {
  int getDuration(String mp3Path) {
    final file = File(mp3Path);
    if (!file.existsSync()) {
      throw FileSystemException('Audio file not found', mp3Path);
    }

    final mp3 = MP3Processor.fromFile(file);
    return mp3.duration.inMilliseconds;
  }
}
