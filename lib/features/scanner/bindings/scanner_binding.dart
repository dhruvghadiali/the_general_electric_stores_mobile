import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/features/scanner/controllers/scanner_controller.dart';

class ScannerBinding extends Bindings {
  @override
  void dependencies() {
    // `put`, not `lazyPut`: the controller opens the camera stream in onInit
    // and the view would otherwise not construct it until first read.
    Get.put<ScannerController>(ScannerController());
  }
}
