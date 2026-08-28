import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/services/auth_service.dart';
import 'package:the_general_electric_stores_mobile/core/utils/app_snackbar.dart';
import 'package:the_general_electric_stores_mobile/features/auth/data/models/user_model.dart';
import 'package:the_general_electric_stores_mobile/features/auth/data/repositories/auth_repository.dart';

/// Settings is the one screen all three roles share, because its job is the
/// same for everyone: show who is signed in, and let them leave.
class SettingsController extends GetxController {
  SettingsController(this._repository, this.role);

  final AuthRepository _repository;
  final UserRole role;

  UserModel? get user => AuthService.to.user.value;

  /// Tells the API first so the refresh token is revoked server-side, then
  /// clears this device either way — a failed call must not strand someone in
  /// a session they asked to leave.
  Future<void> signOut() async {
    try {
      await _repository.signOut(role);
    } on Object {
      AppSnackbar.info('Signed out on this device.');
    } finally {
      await AuthService.to.clear();
      await Get.offAllNamed<void>(AppRoutes.login);
    }
  }
}
