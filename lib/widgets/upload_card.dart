import 'dart:io';

import 'package:flutter/material.dart';

class UploadCard extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onUploadPressed;
  final VoidCallback onTakePhotoPressed;

  const UploadCard({super.key, this.imageFile, required this.onUploadPressed, required this.onTakePhotoPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          SizedBox(
            height: 240,
            child: Center(
              child: imageFile == null
                  ? Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.image_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text('No image selected', style: TextStyle(color: Colors.grey[600])),
                    ])
                  : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(imageFile!, fit: BoxFit.cover, width: double.infinity, height: 240)),
            ),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(onPressed: onUploadPressed, icon: const Icon(Icons.upload_file), label: const Text('Upload Image')),
            const SizedBox(width: 12),
            OutlinedButton.icon(onPressed: onTakePhotoPressed, icon: const Icon(Icons.camera_alt), label: const Text('Take Photo')),
          ])
        ]),
      ),
    );
  }
}
