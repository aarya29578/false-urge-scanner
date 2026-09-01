import 'dart:async';
import '../models/scan_result.dart';

class MockScanner {
  static Future<ScanResult> scan(String imagePath) async {
    // Simulate staged scanning delays
    await Future.delayed(const Duration(seconds: 1)); // scanning
    await Future.delayed(const Duration(seconds: 1)); // detecting
    await Future.delayed(const Duration(seconds: 1)); // analyzing

    // Return mocked results
    final words = <WordResult>[
      WordResult(word: 'Education', status: WordStatus.genuine),
      WordResult(word: 'Certificate', status: WordStatus.genuine),
      WordResult(word: 'Authorized', status: WordStatus.genuine),
      WordResult(word: 'Official', status: WordStatus.fake),
      WordResult(word: 'Verified', status: WordStatus.unknown),
    ];

    // Simple confidence mock
    const confidence = 0.87;

    return ScanResult(imagePath: imagePath, words: words, confidence: confidence);
  }
}
