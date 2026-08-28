import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_exception.dart';
import 'package:the_general_electric_stores_mobile/core/services/camera_permission.dart';
import 'package:the_general_electric_stores_mobile/core/utils/app_snackbar.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/data/models/dashboard_summary.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/data/repositories/dashboard_repository.dart';

/// Loading and failure handling shared by all three dashboards.
///
/// Only that is shared. What each role's dashboard *shows* is decided by its
/// own subclass and its own screen, because the figures are different and the
/// actions behind them are different.
abstract class BaseDashboardController extends GetxController {
  BaseDashboardController(this._repository, this.role);

  final DashboardRepository _repository;
  final UserRole role;

  final Rx<DashboardSummary> summary = DashboardSummary.empty.obs;
  final RxBool isLoading = false.obs;
  final Rxn<ApiException> failure = Rxn<ApiException>();

  bool get hasFailed => failure.value != null;

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  Future<void> load() async {
    isLoading.value = true;
    failure.value = null;

    try {
      summary.value = await _repository.summary(role);
    } on ApiException catch (error) {
      failure.value = error;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshSummary() => load();

  // ------------------------------------------------------------- scanning

  /// Opens the scanner, asking for the camera first.
  ///
  /// The permission is checked here rather than inside the scanner screen so
  /// the user never sees a black viewfinder while a dialog is pending — either
  /// the camera is available and the screen opens, or it never opens and we
  /// say why.
  Future<void> openScanner() async {
    final CameraPermissionResult permission = await CameraPermission.ensure();

    switch (permission) {
      case CameraPermissionResult.granted:
        // Not `Get.toNamed<String>`. GetX's onGenerateRoute always builds a
        // `GetPageRoute<dynamic>`, and `pushNamed<String>` then tries to cast
        // it to `Route<String?>` — which throws, because String is not a top
        // type. `Object?` is, so the cast succeeds and we narrow afterwards.
        // The `Get.toNamed<void>` calls elsewhere work for the same reason.
        final Object? scanned = await Get.toNamed<Object?>(AppRoutes.scanner);
        if (scanned is String && scanned.isNotEmpty) onScanned(scanned);

      case CameraPermissionResult.denied:
        AppSnackbar.info(
          'Scanning needs the camera. Tap scan again to allow it.',
          title: 'Camera not allowed',
        );

      case CameraPermissionResult.permanentlyDenied:
        await _offerSettings();

      case CameraPermissionResult.restricted:
        AppSnackbar.warning(
          'Camera access is blocked on this device by a policy or parental '
          'control.',
          title: 'Camera unavailable',
        );
    }
  }

  /// What a scanned code means to this role. Each dashboard decides, because
  /// the same QR sticker opens a product for one role and a stock line for
  /// another.
  void onScanned(String code);

  /// Codes are often printed as a URL rather than a bare id. Take the last
  /// path segment when it looks like one, otherwise use the value as it is.
  String idFromCode(String code) {
    final Uri? uri = Uri.tryParse(code);
    if (uri != null && uri.hasScheme && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }
    return code;
  }

  Future<void> _offerSettings() async {
    await Get.dialog<void>(
      AlertDialog(
        title: const Text('Camera access needed'),
        content: const Text(
          'Scanning needs the camera, and permission was declined. Turn it on '
          'for this app in Settings.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () {
              Get.back<void>();
              unawaited(CameraPermission.openSettings());
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }
}
