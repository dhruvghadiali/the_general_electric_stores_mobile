import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/utils/app_snackbar.dart';
import 'package:the_general_electric_stores_mobile/features/companies/data/models/company_model.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/constants/scan_purpose.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/models/scan_context.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/models/scan_result.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/models/scanned_code.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/models/scanned_item.dart';

/// Holds the codes read during one scanning session and shows them back.
///
/// The session is one purpose and one company — both settled before this screen
/// opens — and any number of codes. Everything read stays here until the user
/// finishes, so a mis-scan can be spotted and removed while the pallet is still
/// in front of them rather than after the fact.
///
/// Nothing here talks to the API. That is not an omission: there is no endpoint
/// to send these to yet (the warehouse manager's router mounts `/auth`,
/// `/companies` and `/purchases`, and a purchase needs more than a code), so
/// the honest thing is to show exactly what was read and hand it back up.
class ScannedItemsController extends GetxController {
  final RxList<ScannedItem> items = <ScannedItem>[].obs;

  /// True while the camera route is on top, so the screen underneath does not
  /// flash its empty state on the way through.
  final RxBool isScanning = false.obs;

  /// What this session is for, as settled by the two screens before it.
  ///
  /// Null only if the route was opened without its arguments — a deep link, or
  /// a hot reload that dropped them. That is handled by leaving in [onReady]
  /// rather than by throwing: a screen that cannot finish should close, not
  /// take the app down while someone is holding a box.
  ScanContext? get _context {
    final Object? argument = Get.arguments;
    return argument is ScanContext ? argument : null;
  }

  ScanPurpose get purpose => _context?.purpose ?? ScanPurpose.purchase;

  CompanyModel? get company => _context?.company;

  bool get isEmpty => items.isEmpty;

  /// How many readings, and how many different codes among them. Both are
  /// shown because they answer different questions: eleven readings of ten
  /// codes means something was scanned twice.
  int get distinctCount =>
      items.map((ScannedItem item) => item.code).toSet().length;

  @override
  void onReady() {
    super.onReady();

    if (_context == null) {
      AppSnackbar.error('That scan could not be started. Please try again.');
      cancel();
      return;
    }

    // The user pressed "Continue to scan" and expects a camera, not a list of
    // nothing. The first one opens itself; every one after is a deliberate tap.
    if (items.isEmpty) unawaited(scanAnother());
  }

  /// Opens the camera and keeps whatever comes back.
  Future<void> scanAnother() async {
    if (isScanning.value) return;
    isScanning.value = true;

    try {
      // `Object?`, not `ScannedCode`: GetX's onGenerateRoute always builds a
      // `GetPageRoute<dynamic>`, and a non-top-type generic throws on the cast.
      final Object? scanned = await Get.toNamed<Object?>(
        AppRoutes.scannerCamera,
        arguments: purpose,
      );

      if (scanned is! ScannedCode || scanned.value.isEmpty) return;

      // Newest first, so the reading just taken is the one under the thumb
      // rather than somewhere below the fold.
      items.insert(0, ScannedItem.from(scanned));
      unawaited(HapticFeedback.mediumImpact());
    } finally {
      isScanning.value = false;
    }
  }

  /// How many times this exact code has been read this session.
  ///
  /// Repeats are kept rather than refused. A QR this business printed should
  /// appear once and a second reading is a mistake, but a manufacturer's
  /// barcode is shared by every identical unit, so two readings of one EAN is
  /// two cartons. Refusing the second would be wrong half the time; showing
  /// the count is right in both cases and leaves the judgement with the person
  /// holding the goods.
  int occurrencesOf(String code) =>
      items.where((ScannedItem item) => item.code == code).length;

  void removeAt(int index) {
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
  }

  void clear() => items.clear();

  /// Finishes the session and hands every reading back up the flow.
  void done() {
    final CompanyModel? against = company;
    if (items.isEmpty || against == null) {
      cancel();
      return;
    }

    Get.back<Object?>(
      result: ScanResult(
        items: List<ScannedItem>.unmodifiable(items),
        purpose: purpose,
        company: against,
      ),
    );
  }

  /// Leaves with nothing. The caller treats a null result as "cancelled", so
  /// an abandoned session cannot be mistaken for an empty one.
  void cancel() => Get.back<Object?>();

}
