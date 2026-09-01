import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:the_general_electric_stores_mobile/core/utils/logger.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/data/models/scan_purpose.dart';

/// Drives the scanning screen.
///
/// The camera feed is read through the controller's `barcodes` stream rather
/// than the widget's `onDetect` callback — the stream has been stable across
/// mobile_scanner's major versions, and it keeps the detection logic here
/// instead of inside a widget build.
///
/// **The camera is started here, explicitly.** `autoStart` is off and this
/// controller calls [MobileScannerController.start] itself, which is the
/// lifecycle the package documents. The reason is not preference: a start that
/// fails under `autoStart` fails inside the widget, where this app never sees
/// the exception, and the screen shows a black rectangle that looks exactly
/// like a camera that decided not to open. Starting it here means every
/// failure lands in [startError] and on screen with the reason attached.
///
/// [_handled] is the other important bit: a code in frame emits continuously,
/// so without a latch the screen would pop once per frame and take the route
/// under it with it.
class ScannerController extends GetxController with WidgetsBindingObserver {
  /// Both kinds of code, because a warehouse meets both.
  ///
  /// A QR or Data Matrix is something this business printed and carries one of
  /// our own identifiers. The striped barcode down the side of a carton was
  /// printed by whoever made the goods and carries their product code. Someone
  /// holding a box has no reason to care which is which, so the camera reads
  /// either and [ScannedCode.symbology] records what it found.
  ///
  /// Listed explicitly rather than left at the default (which is "everything")
  /// so the detector is only asked for formats that actually turn up on stock,
  /// and so adding one later is a deliberate edit.
  static const List<BarcodeFormat> _formats = <BarcodeFormat>[
    // Two-dimensional: ours.
    BarcodeFormat.qrCode,
    BarcodeFormat.dataMatrix,
    BarcodeFormat.aztec,
    BarcodeFormat.pdf417,
    // One-dimensional: retail and logistics.
    BarcodeFormat.ean13,
    BarcodeFormat.ean8,
    BarcodeFormat.upcA,
    BarcodeFormat.upcE,
    BarcodeFormat.code128,
    BarcodeFormat.code39,
    BarcodeFormat.code93,
    BarcodeFormat.itf,
    BarcodeFormat.codabar,
  ];

  final MobileScannerController scanner = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: _formats,
  );

  final RxBool isTorchOn = false.obs;

  /// True while the camera is being opened — the first frame can take a
  /// noticeable moment on a cold camera, and an unexplained black screen in
  /// that gap is what makes people tap the button again.
  final RxBool isStarting = true.obs;

  /// Why the camera did not open, when it did not. Null while it is fine.
  final Rxn<String> startError = Rxn<String>();

  /// Set by the chooser screen. Only used for the heading — the camera does
  /// not behave differently, and the purpose travels back with the code.
  ScanPurpose get purpose {
    final Object? argument = Get.arguments;
    return argument is ScanPurpose ? argument : ScanPurpose.purchase;
  }

  StreamSubscription<BarcodeCapture>? _subscription;
  bool _handled = false;
  bool _isRunning = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _subscription = scanner.barcodes.listen(_onCapture);
    unawaited(start());
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    unawaited(scanner.dispose());
    super.onClose();
  }

  /// Opens the camera. Safe to call again — a retry button and a return from
  /// the background both land here.
  Future<void> start() async {
    if (_isRunning || _handled) return;

    isStarting.value = true;
    startError.value = null;

    try {
      await scanner.start();
      _isRunning = true;
      AppLogger.d('Scanner started');
    } on MobileScannerException catch (error, stackTrace) {
      // The package's own failures: permission refused at the OS layer, no
      // camera on this device, another app holding it, an unsupported format
      // set. All of them are worth showing verbatim — the message names the
      // cause far better than anything this app could infer.
      startError.value =
          error.errorDetails?.message ?? error.errorCode.name;
      AppLogger.e('Scanner failed to start', error, stackTrace);
    } on Object catch (error, stackTrace) {
      // A MissingPluginException on a hot restart, a platform channel that
      // went away. Without this the future dies and the screen stays blank.
      startError.value = error.toString();
      AppLogger.e('Scanner failed to start', error, stackTrace);
    } finally {
      isStarting.value = false;
    }
  }

  /// The camera has to be handed back when the app goes away — Android will
  /// take it regardless, and coming back to a stopped scanner is what leaves
  /// people staring at a dead preview after answering a phone call.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(start());

      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _isRunning = false;
        unawaited(scanner.stop().catchError((Object _) {}));
    }
  }

  void _onCapture(BarcodeCapture capture) {
    if (_handled) return;

    for (final Barcode barcode in capture.barcodes) {
      final String? value = barcode.rawValue;
      if (value == null || value.trim().isEmpty) continue;

      _handled = true;
      AppLogger.d('Scanned ${barcode.format.name}: ${value.trim()}');

      Get.back<Object?>(
        result: ScannedCode(
          value: value.trim(),
          symbology: _symbologyOf(barcode.format),
          formatName: barcode.format.name,
        ),
      );
      return;
    }
  }

  /// Maps the scanner's format to the only distinction the rest of the app
  /// makes: did we print this code, or did the manufacturer?
  ScanSymbology _symbologyOf(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
      case BarcodeFormat.dataMatrix:
      case BarcodeFormat.aztec:
      case BarcodeFormat.pdf417:
        return ScanSymbology.qr;

      case BarcodeFormat.ean13:
      case BarcodeFormat.ean8:
      case BarcodeFormat.upcA:
      case BarcodeFormat.upcE:
      case BarcodeFormat.code128:
      case BarcodeFormat.code39:
      case BarcodeFormat.code93:
      case BarcodeFormat.itf:
      case BarcodeFormat.codabar:
        return ScanSymbology.barcode;

      // `unknown`, `all`, and anything mobile_scanner adds in a later version.
      // Classifying by guess would be worse than saying so.
      default:
        return ScanSymbology.unknown;
    }
  }

  Future<void> toggleTorch() async {
    // A torch call before the camera is up throws on both platforms.
    if (!_isRunning) return;

    try {
      await scanner.toggleTorch();
      isTorchOn.value = !isTorchOn.value;
    } on Object catch (error) {
      // Plenty of devices have no torch. Not worth interrupting a scan over.
      AppLogger.w('Torch unavailable: $error');
    }
  }

  void cancel() => Get.back<Object?>();
}
