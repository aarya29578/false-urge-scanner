import 'package:flutter/services.dart';

import 'detection_service.dart';

class ProtectionModeService {
  static const MethodChannel _channel = MethodChannel('word_scanner/protection');

  static Future<bool> checkOverlayPermission() async {
    try {
      final granted = await _channel.invokeMethod<bool>('checkOverlayPermission');
      return granted ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> openOverlaySettings() async {
    try {
      final result = await _channel.invokeMethod<bool>('openOverlaySettings');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> enableProtectionMode() async {
    try {
      final result = await _channel.invokeMethod<bool>('enableProtectionMode');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> disableProtectionMode() async {
    try {
      final result = await _channel.invokeMethod<bool>('disableProtectionMode');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> triggerTestAlert() async {
    try {
      final result = await MockDetectionService().getResult();
      final ok = await _channel.invokeMethod<bool>('triggerTestAlert', {
        'title': result.title,
        'summary': result.summary,
        'confidence': result.confidence,
        'indicators': result.indicators,
      });
      return ok ?? false;
    } on PlatformException {
      return false;
    }
  }
}
