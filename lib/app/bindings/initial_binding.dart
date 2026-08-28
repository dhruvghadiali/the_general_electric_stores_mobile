import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_client.dart';
import 'package:the_general_electric_stores_mobile/core/services/auth_service.dart';
import 'package:the_general_electric_stores_mobile/core/services/connectivity_service.dart';
import 'package:the_general_electric_stores_mobile/core/services/storage_service.dart';

/// Everything that must exist before the first route builds.
///
/// The order matters: storage backs the auth service, and the API client's
/// auth interceptor reads from storage. `putAsync` keeps that order honest —
/// each service is fully initialised before the next one asks for it.
class InitialBinding {
  const InitialBinding._();

  static Future<void> init() async {
    await Get.putAsync<StorageService>(
      () => StorageService().init(),
      permanent: true,
    );

    await Get.putAsync<AuthService>(
      () => AuthService().init(),
      permanent: true,
    );

    await Get.putAsync<ConnectivityService>(
      () => ConnectivityService().init(),
      permanent: true,
    );

    final ApiClient api = await Get.putAsync<ApiClient>(
      () => ApiClient().init(),
      permanent: true,
    );

    // The network layer signals a dead session; the router decides what that
    // means. Wiring it here keeps `core/network` free of route imports.
    api.onSessionExpired = () async {
      if (Get.currentRoute == AppRoutes.login) return;
      await AuthService.to.clear();
      await Get.offAllNamed<void>(AppRoutes.login);
    };
  }
}
