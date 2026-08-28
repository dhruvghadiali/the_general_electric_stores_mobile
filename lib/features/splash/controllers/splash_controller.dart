import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_exception.dart';
import 'package:the_general_electric_stores_mobile/core/services/auth_service.dart';
import 'package:the_general_electric_stores_mobile/core/utils/logger.dart';
import 'package:the_general_electric_stores_mobile/features/auth/data/repositories/auth_repository.dart';

/// Decides where a cold start lands.
///
/// A stored token is not proof of a live session, so it is confirmed against
/// `/{role}/me` before the app trusts it. A 401 there means the token is dead:
/// the session is cleared and the user goes to login rather than into a shell
/// that will fail on its first request.
class SplashController extends GetxController {
  SplashController(this._repository);

  final AuthRepository _repository;

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

      // Which auth router this session belongs to. No role means no path to
      // confirm against, so the session cannot be trusted.
      final UserRole? role = AuthService.to.role.value;
      if (role == null) {
        await AuthService.to.clear();
        return AppRoutes.login;
      }

      await AuthService.to.setUser(await _repository.me(role));
      return AppRoutes.shellFor(role);
    } on ApiException catch (error) {
      if (error.isUnauthorized || error.isForbidden) {
        await AuthService.to.clear();
        return AppRoutes.login;
      }

      // Offline or the API is down: fall back to the cached user rather than
      // signing someone out because their train went into a tunnel.
      AppLogger.w('Could not confirm session: ${error.message}');
      final UserRole? cached = AuthService.to.role.value;
      return (AuthService.to.isLoggedIn && cached != null)
          ? AppRoutes.shellFor(cached)
          : AppRoutes.login;
    } on Object catch (error, stackTrace) {
      // Anything that is not an ApiException — a keychain PlatformException,
      // a MissingPluginException, a parse error on an unexpected payload.
      // Without this the future dies here and the splash screen never leaves,
      // which looks like a hang rather than a failure.
      AppLogger.e('Splash could not resolve a route', error, stackTrace);
      return AppRoutes.login;
    }
  }
}
