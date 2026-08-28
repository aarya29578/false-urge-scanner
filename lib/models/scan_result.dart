enum WordStatus { genuine, fake, unknown }

class WordResult {
  final String word;
  final WordStatus status;

  WordResult({required this.word, required this.status});
}

class ScanResult {
  final String? imagePath;
  final List<WordResult> words;
  final double confidence; // 0.0 - 1.0

  ScanResult({this.imagePath, required this.words, required this.confidence});

  bool get overallGenuine {
    // Simple rule: if any fake exists -> not genuine
    return words.every((w) => w.status != WordStatus.fake);
  }
}
