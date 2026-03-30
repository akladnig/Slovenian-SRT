import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String? _selectedFile;
  String? _outputPath;
  String _status = 'Select an audio file to transcribe';
  bool _isTranscribing = false;
  String? _error;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'flac', 'ogg'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = result.files.single.path;
        _outputPath = null;
        _status = 'Ready to transcribe: ${p.basename(_selectedFile!)}';
        _error = null;
      });
    }
  }

  Future<void> _transcribe() async {
    if (_selectedFile == null) return;

    setState(() {
      _isTranscribing = true;
      _status = 'Transcribing audio...';
      _error = null;
    });

    try {
      final modelPath =
          Platform.environment['WHISPER_MODEL'] ??
          '${Platform.environment['HOME']}/.cache/whisper/ggml-base.bin';

      final outputPath = '${p.withoutExtension(_selectedFile!)}_transcription';

      final result = await Process.run(
        '/opt/homebrew/bin/whisper-cli',
        [
          '-m',
          modelPath,
          '-f',
          _selectedFile!,
          '-osrt',
          '-of',
          outputPath,
          '-l',
          'auto',
        ],
      );

      if (result.exitCode != 0) {
        throw Exception(
          result.stderr.toString().isNotEmpty
              ? result.stderr.toString()
              : 'Transcription failed',
        );
      }

      final srtPath = '$outputPath.srt';
      if (await File(srtPath).exists()) {
        setState(() {
          _outputPath = srtPath;
          _status = 'Transcription complete!';
        });
      } else {
        throw Exception('SRT file was not generated');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _status = 'Error during transcription';
      });
    } finally {
      setState(() {
        _isTranscribing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Whisper Transcriber'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.audio_file,
                size: 80,
                color: _selectedFile != null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).disabledColor,
              ),
              const SizedBox(height: 24),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (_outputPath != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Saved: ${p.basename(_outputPath!)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _isTranscribing ? null : _pickFile,
                icon: const Icon(Icons.folder_open),
                label: const Text('Select Audio File'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _selectedFile != null && !_isTranscribing
                    ? _transcribe
                    : null,
                icon: _isTranscribing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.mic),
                label: Text(_isTranscribing ? 'Transcribing...' : 'Transcribe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
