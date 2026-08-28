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
        title: const Text('Scan QR code'),
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
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          MobileScanner(
            controller: controller.scanner,
            errorBuilder: (
              BuildContext context,
              MobileScannerException error,
            ) =>
                _CameraUnavailable(error: error),
          ),
          const _ViewfinderOverlay(),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppDimens.xxl,
            child: Text(
              'Point the camera at a QR code',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

/// A cut-out square with the rest of the frame dimmed, so it is obvious where
/// the code has to sit.
class _ViewfinderOverlay extends StatelessWidget {
  const _ViewfinderOverlay();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double side = constraints.biggest.shortestSide * 0.68;

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
                    height: side,
                    width: side,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: side,
              width: side,
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
/// an emulator with no camera, hardware trouble. Saying so beats a black
/// rectangle.
class _CameraUnavailable extends StatelessWidget {
  const _CameraUnavailable({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    return Center(
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
              error.errorDetails?.message ?? error.errorCode.name,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}
