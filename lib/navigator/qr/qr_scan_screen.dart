import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  late MobileScannerController _controller;
  bool _isScanned = false; // tránh xử lý nhiều lần

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
    );
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose(); // giải phóng camera khi thoát
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double scanBoxSize = 250;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quét QR"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            fit: BoxFit.cover,
            onDetect: (capture) {
              if (_isScanned) return; // đã quét rồi thì bỏ qua
              for (final barcode in capture.barcodes) {
                if (barcode.rawValue != null) {
                  _isScanned = true;
                  _controller.stop(); // dừng camera
                  Navigator.pop(context, barcode.rawValue); // trả kết quả về
                  break;
                }
              }
            },
          ),
          // Khung quét
          Center(
            child: Container(
              width: scanBoxSize,
              height: scanBoxSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
