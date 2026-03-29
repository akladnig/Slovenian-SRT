import 'dart:io';
import 'package:srt_generator/srt_generator.dart';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Usage: srt_generator <base_filename>');
    print('  Generates a .srt subtitle file from .mp3 and .md files');
    return;
  }

  final basePath = arguments.first;

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
