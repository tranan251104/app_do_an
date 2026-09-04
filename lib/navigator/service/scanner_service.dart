import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:app_do_an/core/logging/app_logger.dart';

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
      AppLogger.repo('QR_SCAN', 'Scanner start requested');
      await instance.start();
      AppLogger.success('QR_SCAN', 'Scanner started');
    } catch (e, stackTrace) {
      AppLogger.error('QR_SCAN', 'Scanner start failed', error: e, stackTrace: stackTrace);
    } finally {
      _isOperating = false;
    }
  }

  static Future<void> stop() async {
    if (!instance.value.isRunning || _isOperating) return;
    _isOperating = true;
    try {
      AppLogger.repo('QR_SCAN', 'Scanner stop requested');
      await instance.stop();
      AppLogger.success('QR_SCAN', 'Scanner stopped');
    } catch (e, stackTrace) {
      AppLogger.error('QR_SCAN', 'Scanner stop failed', error: e, stackTrace: stackTrace);
    } finally {
      _isOperating = false;
    }
  }

  static bool get isStarted => instance.value.isRunning;
}
