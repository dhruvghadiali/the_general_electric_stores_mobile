import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/services/auth_service.dart';
import 'package:the_general_electric_stores_mobile/core/utils/logger.dart';

/// Decides where a cold start lands.
///
/// The stored token is taken at face value, because there is nothing to check
/// it against: the API mounts no `/me` and no refresh route, so the signin JWT
/// is the entire session. The first real request a shell makes is what finds
/// out whether it is still good, and a 401 there sends the user back to login
/// through `AuthInterceptor`.
class SplashController extends GetxController {

  /// Long enough for the logo not to flash, short enough not to feel slow.
  static const Duration _minimumDisplay = Duration(milliseconds: 900);

  @override
  void onReady() {
    super.onReady();
    _decide();
  }

  Future<void> _decide() async {
    final Future<void> minimum = Future<void>.delayed(_minimumDisplay);
    final String target = await _resolveTarget();
    await minimum;
    await Get.offAllNamed<void>(target);
  }

  Future<String> _resolveTarget() async {
    try {
      // Inside the try: reading the keychain can itself throw, and a throw
      // here would strand the splash exactly like a throw further down.
      if (!await AuthService.to.hasStoredToken()) return AppRoutes.login;

      // Which role's router this session belongs to. Without it there is no
      // shell to open and no path any request could be built against, so a
      // token with no role beside it is not a session.
      final UserRole? role = AuthService.to.role.value;
      if (role == null) {
        await AuthService.to.clear();
        return AppRoutes.login;
      }

      return AppRoutes.shellFor(role);
    } on Object catch (error, stackTrace) {
      // A keychain PlatformException, a MissingPluginException, a corrupt
      // cached record. Without this the future dies here and the splash screen
      // never leaves, which looks like a hang rather than a failure.
      AppLogger.e('Splash could not resolve a route', error, stackTrace);
      return AppRoutes.login;
    }
  }
}
