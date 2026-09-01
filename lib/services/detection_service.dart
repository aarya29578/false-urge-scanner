import '../models/detection_result.dart';

abstract class DetectionService {
  Future<DetectionResult> getResult();
}

class MockDetectionService implements DetectionService {
  @override
  Future<DetectionResult> getResult() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return const DetectionResult(
      title: 'Protection Alert',
      summary: 'Potentially suspicious content detected',
      confidence: 78,
      indicators: [
        'Example indicator detected',
        'Example warning signal',
        'Verification required',
      ],
    );
  }
}
