class DetectionResult {
  final String title;
  final String summary;
  final int confidence;
  final List<String> indicators;

  const DetectionResult({
    required this.title,
    required this.summary,
    required this.confidence,
    required this.indicators,
  });
}
