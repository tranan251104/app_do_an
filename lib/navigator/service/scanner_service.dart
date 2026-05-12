import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/foundation.dart';

class ScannerService {
  static final MobileScannerController instance = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    autoStart: false,
  );

  static bool _isOperating = false;

  static Future<void> start() async {
    if (instance.value.isRunning || _isOperating) return;
    _isOperating = true;
    try {
      debugPrint("📸 ScannerService: Starting...");
      await instance.start();
    } catch (e) {
      debugPrint("❌ ScannerService Start Error: $e");
    } finally {
      _isOperating = false;
    }
  }

  static Future<void> stop() async {
    if (!instance.value.isRunning || _isOperating) return;
    _isOperating = true;
    try {
      debugPrint("🛑 ScannerService: Stopping...");
      await instance.stop();
    } catch (e) {
      debugPrint("❌ ScannerService Stop Error: $e");
    } finally {
      _isOperating = false;
    }
  }

  static bool get isStarted => instance.value.isRunning;
}
