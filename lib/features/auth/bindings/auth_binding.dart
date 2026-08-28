import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/network/api_client.dart';
import 'package:the_general_electric_stores_mobile/features/auth/controllers/login_controller.dart';
import 'package:the_general_electric_stores_mobile/features/auth/data/repositories/auth_repository.dart';

/// Dependencies for the login route.
///
/// `lazyPut` means nothing is constructed until the page actually asks for it,
/// and GetX disposes the controller when the route is popped.
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository(ApiClient.to), fenix: true);
    Get.lazyPut<LoginController>(() => LoginController(Get.find()));
  }
}
