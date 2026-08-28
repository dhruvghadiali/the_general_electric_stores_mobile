import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/constants/storage_keys.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/services/storage_service.dart';
import 'package:the_general_electric_stores_mobile/core/utils/logger.dart';
import 'package:the_general_electric_stores_mobile/features/auth/data/models/user_model.dart';

/// Who is signed in, for the lifetime of the process.
///
/// This is a service rather than a controller because it outlives every route:
/// a page can be disposed, the session cannot. Screens watch [user] and
/// [isLoggedIn]; nothing else caches the current user.
class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  final Rxn<UserModel> user = Rxn<UserModel>();

  /// The role this session was opened under — which auth router signed us in.
  /// Every later auth call is scoped by it, so it is restored before the
  /// first frame and cleared with the session.
  final Rxn<UserRole> role = Rxn<UserRole>();

  bool get isLoggedIn => user.value != null;

  String? get userType => user.value?.userType ?? role.value?.value;

  bool hasRole(String role) => userType == role;

  Future<AuthService> init() async {
    role.value = StorageService.to.signedInRole;

    // Restore the cached user so the first frame after a cold start already
    // knows who this is. The token is what actually authorises the API call.
    final Map<String, dynamic>? cached =
        StorageService.to.readJson(StorageKeys.user);
    if (cached != null) {
      try {
        user.value = UserModel.fromJson(cached);
      } on Object catch (error, stackTrace) {
        AppLogger.e('Could not restore cached user', error, stackTrace);
        await StorageService.to.remove(StorageKeys.user);
      }
    }
    return this;
  }

  /// True when a token exists on this device — not proof that it is still
  /// valid. `AuthController.bootstrap` confirms it against the API.
  Future<bool> hasStoredToken() async {
    final String? token = await StorageService.to.accessToken;
    return token != null && token.isNotEmpty;
  }

  Future<void> saveSession(AuthSession session, UserRole signedInAs) async {
    await StorageService.to.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    role.value = signedInAs;
    await StorageService.to.saveSignedInRole(signedInAs);
    await setUser(session.user);
  }

  Future<void> setUser(UserModel value) async {
    user.value = value;
    await StorageService.to.writeJson(StorageKeys.user, value.toJson());
  }

  Future<void> clear() async {
    user.value = null;
    role.value = null;
    await StorageService.to.clearSession();
  }
}
