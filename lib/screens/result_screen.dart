import 'dart:io';

import 'package:flutter/material.dart';
import '../models/scan_result.dart';

class ResultScreen extends StatelessWidget {
  final ScanResult result;

  const ResultScreen({super.key, required this.result});

  Color _statusColor(WordStatus status) {
    switch (status) {
      case WordStatus.genuine:
        return Colors.green;
      case WordStatus.fake:
        return Colors.red;
      case WordStatus.unknown:
        return Colors.orange;
    }
  }

  IconData _statusIcon(WordStatus status) {
    switch (status) {
      case WordStatus.genuine:
        return Icons.check_circle_outline;
      case WordStatus.fake:
        return Icons.report_gmailerrorred_outlined;
      case WordStatus.unknown:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final overallText = result.overallGenuine ? 'Words appear genuine' : 'Potential fake words detected';

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Result')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: result.imagePath != null ? Image.file(File(result.imagePath!), height: 200, width: double.infinity, fit: BoxFit.cover) : Container(height: 200, color: Colors.grey[200]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Text(overallText, style: Theme.of(context).textTheme.titleLarge)),
              Text('${(result.confidence * 100).toStringAsFixed(0)}%', style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.grey[700]))
            ]),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.separated(
                    itemCount: result.words.length,
                    separatorBuilder: (_, __) => const Divider(height: 12),
                    itemBuilder: (context, index) {
                      final w = result.words[index];
                      return ListTile(
                        leading: Icon(_statusIcon(w.status), color: _statusColor(w.status)),
                        title: Text(w.word, style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: Text(w.status.name.toUpperCase(), style: TextStyle(color: _statusColor(w.status), fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Padding(padding: EdgeInsets.symmetric(vertical: 14.0), child: Text('Scan Another Image')),
                ),
              )
            ])
          ]),
        ),
      ),
    );
  }
}
