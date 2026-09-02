import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_exception.dart';
import 'package:the_general_electric_stores_mobile/core/services/camera_permission.dart';
import 'package:the_general_electric_stores_mobile/core/utils/app_snackbar.dart';
import 'package:the_general_electric_stores_mobile/core/utils/logger.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/data/models/dashboard_summary.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/models/scan_result.dart';

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

  /// Starts a scan: permission, then the purpose chooser, then the camera.
  ///
  /// The permission is checked here rather than deeper in so the user is never
  /// walked through a chooser only to be refused the camera at the end of it.
  Future<void> openScanner() async {
    final CameraPermissionResult permission = await CameraPermission.ensure();

    switch (permission) {
      case CameraPermissionResult.granted:
        // Not `Get.toNamed<ScanResult>`. GetX's onGenerateRoute always builds
        // a `GetPageRoute<dynamic>`, and a non-top-type generic makes
        // `pushNamed` throw on the cast. `Object?` is a top type, so the cast
        // succeeds and we narrow afterwards. The `Get.toNamed<void>` calls
        // elsewhere work for the same reason.
        final Object? scanned = await Get.toNamed<Object?>(AppRoutes.scanner);
        if (scanned is ScanResult && scanned.isNotEmpty) {
          onScanned(scanned);
        }

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

  /// What a finished scanning session means to this role.
  ///
  /// The default acknowledges it and stops there, and that is the honest
  /// behaviour today rather than a placeholder. Every role used to push a
  /// detail route built from the scanned string — `/products/<code>` or
  /// `/stocks/<code>` — and all three were wrong in the same way: a scanned
  /// code is not a record id. It is either a `product_code` a manufacturer
  /// printed, or an identifier of ours that no endpoint currently accepts. The
  /// warehouse manager's case is the clearest: there is no stocks router on the
  /// API at all.
  ///
  /// The codes have been shown, kept and handed back. Sending them anywhere
  /// needs two things that do not exist yet:
  ///
  ///  * a lookup for barcodes — `product_code` is in the product list's
  ///    `search_fields`, so `GET /{role}/products?search=<code>` would resolve
  ///    one, for the two roles that have a products router;
  ///  * a destination for the session — [ScanResult.purpose] distinguishes
  ///    stock arriving from stock leaving, and `POST /warehouse-manager/
  ///    purchases` is the closest thing the API has to a home for the first.
  ///
  /// A role that grows a real destination overrides this.
  void onScanned(ScanResult result) {
    final String reading = result.count == 1 ? 'code' : 'codes';
    AppSnackbar.success(
      '${result.count} $reading scanned for ${result.company.name} '
      '(${result.purpose.label.toLowerCase()}).',
      title: 'Scan finished',
    );
  }

  /// Codes are often printed as a URL rather than a bare id. Take the last
  /// path segment when it looks like one, otherwise use the value as it is.
  ///
  /// A one-dimensional barcode has no scheme, so it falls through unchanged —
  /// which is correct as far as it goes, but see [onScanned]: unchanged still
  /// means it is a product code being used where an id is expected.
  ///
  /// Whatever comes out is safe to put in a route: `AppRoutes` encodes the
  /// segment. It is not necessarily safe to *look up* — a value that is not an
  /// id will simply not be found, which is a 404 rather than a crash.
  String idFromCode(String code) {
    final String value = code.trim();

    final Uri? uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }

    // Logged rather than cleaned up. A code carrying slashes or spaces is
    // almost certainly not one of our ids — a scheme-less URL, or a label
    // encoding more than an identifier — and guessing which part of it is the
    // id would turn a visible 404 into a silent lookup of the wrong record.
    if (value.contains(RegExp(r'[\s/?#]'))) {
      AppLogger.w('Scanned code does not look like an id: "$value"');
    }

    return value;
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
