import 'dart:async';

import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/network/api_client.dart';
import 'package:the_general_electric_stores_mobile/features/companies/data/repositories/company_repository.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/purchase_stock_controller.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/scan_company_controller.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/scan_options_controller.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/scanned_items_controller.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/scanner_controller.dart';

class ScanOptionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScanOptionsController>(ScanOptionsController.new);
  }
}

class ScanCompanyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompanyRepository>(
      () => CompanyRepository(ApiClient.to),
      fenix: true,
    );
    // `put`, not `lazyPut`: the controller fetches the company list in onInit.
    Get.put<ScanCompanyController>(ScanCompanyController(Get.find()));
  }
}

class PurchaseStockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompanyRepository>(
      () => CompanyRepository(ApiClient.to),
      fenix: true,
    );
    // `put`, not `lazyPut`: the controller fetches the supplier list in onInit.
    Get.put<PurchaseStockController>(PurchaseStockController(Get.find()));
  }
}

class ScannedItemsBinding extends Bindings {
  @override
  void dependencies() {
    // `put`, not `lazyPut`: the controller opens the camera from `onReady`,
    // and a lazy one would not exist to have an `onReady`.
    //
    // Fresh every time for the same reason the scanner is: a session's codes
    // belong to that session, and inheriting the last pallet's readings would
    // be worse than losing them.
    if (Get.isRegistered<ScannedItemsController>()) {
      unawaited(Get.delete<ScannedItemsController>(force: true));
    }
    Get.put<ScannedItemsController>(ScannedItemsController());
  }
}

class ScannerBinding extends Bindings {
  @override
  void dependencies() {
    // Delete first, and this is not belt-and-braces.
    //
    // `Get.put` keeps an existing registration rather than replacing it, and a
    // `MobileScannerController` cannot be reused once disposed. So if an
    // instance from a previous scan survived its route being popped, this
    // screen would be handed a controller whose camera is already gone — which
    // shows up as a scanner that worked the first time and is black every time
    // after. Forcing a fresh one costs nothing and removes the whole class.
    if (Get.isRegistered<ScannerController>()) {
      unawaited(Get.delete<ScannerController>(force: true));
    }

    // `put`, not `lazyPut`: the controller opens the camera in onInit and the
    // view would otherwise not construct it until first read.
    Get.put<ScannerController>(ScannerController());
  }
}
