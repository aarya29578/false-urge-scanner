import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/mock_scanner.dart';
import '../models/scan_result.dart';
import '../widgets/upload_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? _image;
  bool _scanning = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source, maxWidth: 2048);
      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image selection cancelled.')));
        return;
      }
      setState(() => _image = image);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> _startScan() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image first.')));
      return;
    }

    setState(() => _scanning = true);

    // Show scanning dialog with animated staged messages
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const _ScanningDialog();
      },
    );

    final result = await MockScanner.scan(_image!.path);

    // Close dialog
    if (mounted) Navigator.of(context).pop();

    setState(() => _scanning = false);

    // Navigate to result screen
    if (mounted) {
      Navigator.of(context).pushNamed('/result', arguments: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word Scanner')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text('Upload or take a photo of any document or image to scan words inside it.',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 20),
              UploadCard(
                imageFile: _image != null ? File(_image!.path) : null,
                onUploadPressed: () => _pickImage(ImageSource.gallery),
                onTakePhotoPressed: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _scanning ? null : _startScan,
                icon: const Icon(Icons.search),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text('Scan Image', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() => _image = null);
                },
                child: const Text('Clear selection'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanningDialog extends StatefulWidget {
  const _ScanningDialog({super.key});

  @override
  State<_ScanningDialog> createState() => _ScanningDialogState();
}

class _ScanningDialogState extends State<_ScanningDialog> with SingleTickerProviderStateMixin {
  final List<String> _steps = ['Scanning image...', 'Detecting words...', 'Analyzing results...'];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _cycle();
  }

  void _cycle() async {
    for (var i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _index = i);
      });
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 6),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(_steps[_index], style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('This is a mocked scan — no data is sent anywhere.'),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
