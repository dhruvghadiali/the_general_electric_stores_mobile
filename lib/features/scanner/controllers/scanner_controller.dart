import 'dart:async';

import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Drives the scanning screen.
///
/// The camera feed is read through the controller's `barcodes` stream rather
/// than the widget's `onDetect` callback — the stream has been stable across
/// mobile_scanner's major versions, and it keeps the detection logic here
/// instead of inside a widget build.
///
/// [_handled] is the important bit: a QR code in frame emits continuously, so
/// without a latch the screen would pop once per frame and take the route
/// under it with it.
class ScannerController extends GetxController {
  final MobileScannerController scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const <BarcodeFormat>[BarcodeFormat.qrCode],
  );

  final RxBool isTorchOn = false.obs;

  StreamSubscription<BarcodeCapture>? _subscription;
  bool _handled = false;

  @override
  void onInit() {
    super.onInit();
    _subscription = scanner.barcodes.listen(_onCapture);
  }

  @override
  void onClose() {
    unawaited(_subscription?.cancel());
    unawaited(scanner.dispose());
    super.onClose();
  }

  void _onCapture(BarcodeCapture capture) {
    if (_handled) return;

    for (final Barcode barcode in capture.barcodes) {
      final String? value = barcode.rawValue;
      if (value == null || value.trim().isEmpty) continue;

      _handled = true;
      Get.back<Object?>(result: value.trim());
      return;
    }
  }

  Future<void> toggleTorch() async {
    await scanner.toggleTorch();
    isTorchOn.value = !isTorchOn.value;
  }

  void cancel() => Get.back<Object?>();
}
