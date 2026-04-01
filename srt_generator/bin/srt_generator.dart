import 'dart:io';
import 'package:srt_generator/srt_generator.dart';

const _supportedExtensions = ['.md', '.mp3', '.m4a', '.mov'];

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Usage: slovenian-srt <file.md|file.mp3|file.m4a|file.mov>');
    print('  Generates a .srt subtitle file from audio and transcript files');
    return;
  }

  final inputPath = arguments.first;
  final file = File(inputPath);

  if (!file.existsSync()) {
    print('Error: File not found: $inputPath');
    exit(1);
  }

  final extension = _getExtension(inputPath);
  if (extension == null || !_supportedExtensions.contains(extension)) {
    final actualExtension = _getActualExtension(inputPath);
    print('Error: Unsupported file type: $actualExtension');
    print('Supported types: ${_supportedExtensions.join(', ')}');
    exit(1);
  }

  final basePath = inputPath.substring(0, inputPath.length - extension.length);

  try {
    final generator = SrtGenerator();
    final outputPath = generator.generate(basePath);
    print('Generated: $outputPath');
  } on FileSystemException catch (e) {
    print('Error: ${e.message}');
    exit(1);
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

String? _getExtension(String path) {
  for (final ext in _supportedExtensions) {
    if (path.toLowerCase().endsWith(ext)) {
      return ext;
    }
  }
  return null;
}

String _getActualExtension(String path) {
  final lastDot = path.lastIndexOf('.');
  if (lastDot == -1 || lastDot == path.length - 1) {
    return '(no extension)';
  }
  return path.substring(lastDot);
}
