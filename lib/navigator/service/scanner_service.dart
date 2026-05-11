import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerService {
  // 🔹 Bộ điều khiển duy nhất cho toàn App
  static final MobileScannerController instance = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    autoStart: false,
  );

  static bool _isStarted = false;

  static Future<void> start() async {
    if (_isStarted) return;
    try {
      await instance.start();
      _isStarted = true;
    } catch (e) {
      print("Scanner Service Start Error: $e");
    }
  }

  static Future<void> stop() async {
    if (!_isStarted) return;
    try {
      await instance.stop();
      _isStarted = false;
    } catch (e) {
      print("Scanner Service Stop Error: $e");
    }
  }

  static bool get isStarted => _isStarted;
}
