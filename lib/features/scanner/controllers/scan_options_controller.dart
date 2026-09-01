import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/data/models/scan_purpose.dart';

/// The first step of a scan: what is this for?
///
/// It owns its hop so neither the dashboard nor the screens below it need to
/// know the shape of the flow — the dashboard asks for a scan and eventually
/// gets a [ScanResult], and each screen only talks to the one after it.
class ScanOptionsController extends GetxController {
  Future<void> choose(ScanPurpose purpose) async {
    // `Object?`, not `ScanResult`: GetX's onGenerateRoute always builds a
    // `GetPageRoute<dynamic>`, and a non-top-type generic makes the cast throw.
    final Object? result = await Get.toNamed<Object?>(
      AppRoutes.scanCompany,
      arguments: purpose,
    );

    if (result is! ScanResult) return;

    // Close this screen too, so the dashboard is what the user comes back to
    // rather than a question they have already answered.
    Get.back<Object?>(result: result);
  }

  void cancel() => Get.back<Object?>();
}
