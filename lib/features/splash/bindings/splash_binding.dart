import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/features/splash/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // `put`, not `lazyPut`. A lazy controller is only constructed when
    // something calls `Get.find()` for it, and SplashView deliberately reads
    // nothing from this controller — it is a static logo. That would leave
    // `onReady` never firing and the app parked on the splash screen forever.
    // Any controller whose whole job is a side effect must be eager.
    Get.put<SplashController>(SplashController());
  }
}
