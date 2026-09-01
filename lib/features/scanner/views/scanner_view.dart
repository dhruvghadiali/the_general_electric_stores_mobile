import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/scanner_controller.dart';

/// The camera screen. Pops with the scanned string, or with null if cancelled.
///
/// Deliberately dark chrome regardless of theme: the viewfinder is the screen,
/// and a light app bar over a camera feed reads as a bug.
class ScannerView extends GetView<ScannerController> {
  const ScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(controller.purpose.label),
        leading: IconButton(
          onPressed: controller.cancel,
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cancel',
        ),
        actions: <Widget>[
          Obx(
            () => IconButton(
              onPressed: controller.toggleTorch,
              icon: Icon(
                controller.isTorchOn.value
                    ? Icons.flashlight_on_rounded
                    : Icons.flashlight_off_rounded,
              ),
              tooltip: 'Torch',
            ),
          ),
        ],
      ),
      // The failure states sit *above* the feed rather than replacing it, so
      // there is never a moment where the screen is black and says nothing.
      body: Obx(() {
        final String? error = controller.startError.value;

        if (error != null) {
          return _CameraUnavailable(
            message: error,
            onRetry: controller.start,
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            MobileScanner(
              controller: controller.scanner,
              errorBuilder: (
                BuildContext context,
                MobileScannerException error,
              ) =>
                  _CameraUnavailable(
                message: error.errorDetails?.message ?? error.errorCode.name,
                onRetry: controller.start,
              ),
            ),
            const _ViewfinderOverlay(),
            if (controller.isStarting.value)
              const ColoredBox(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white70),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: AppDimens.xxl,
              child: Text(
                controller.isStarting.value
                    ? 'Opening the camera…'
                    : 'Point the camera at a QR code or barcode',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white70),
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// A cut-out window with the rest of the frame dimmed, so it is obvious where
/// the code has to sit.
///
/// Wider than it is tall, because the two things being scanned want opposite
/// shapes: a QR is square, a barcode is a long thin stripe. A square window
/// tells someone holding a carton to centre a 90mm barcode inside a 200px box,
/// which they cannot do without backing away until the bars stop resolving.
/// The 3:2 window fits a barcode along its length and still leaves a QR the
/// full height, so neither is being asked to fit the other's shape.
class _ViewfinderOverlay extends StatelessWidget {
  const _ViewfinderOverlay();

  /// Window height as a fraction of its width.
  static const double _aspect = 2 / 3;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size size = constraints.biggest;

        // Bounded on both axes so a landscape phone gets a window that still
        // fits on screen rather than one running off the sides.
        final double width = <double>[
          size.width * 0.86,
          size.height * 0.7 / _aspect,
          420,
        ].reduce((double a, double b) => a < b ? a : b);
        final double height = width * _aspect;

        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.black54,
                BlendMode.srcOut,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  // srcOut punches the second child out of the first, so this
                  // one has to be opaque for the hole to appear.
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Container(
                    height: height,
                    width: width,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 2),
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The camera can fail after permission is granted — another app holding it,
/// a simulator with no camera at all, hardware trouble. Saying so, with the
/// platform's own words and a way to try again, beats a black rectangle.
class _CameraUnavailable extends StatelessWidget {
  const _CameraUnavailable({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.videocam_off_outlined,
                size: AppDimens.xxxl,
                color: Colors.white70,
              ),
              const SizedBox(height: AppDimens.lg),
              Text(
                'The camera could not be started',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppDimens.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white60),
              ),
              const SizedBox(height: AppDimens.xl),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
