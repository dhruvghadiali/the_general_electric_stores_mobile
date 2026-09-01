import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/services/auth_service.dart';
import 'package:the_general_electric_stores_mobile/features/auth/data/models/user_model.dart';

/// Settings is the one screen all three roles share, because its job is the
/// same for everyone: show who is signed in, and let them leave.
class SettingsController extends GetxController {
  SettingsController(this.role);

  final UserRole role;

  UserModel? get user => AuthService.to.user.value;

  /// Signing out is local, and that is not a shortcut.
  ///
  /// The API mounts no signout route on any role's router, and the token it
  /// issues is a self-contained JWT with an expiry — there is no server-side
  /// session to end and nothing that could revoke it early. Clearing the token
  /// off this device is the whole of what signing out can mean today; the
  /// credential itself stops being accepted when it expires.
  Future<void> signOut() async {
    await AuthService.to.clear();
    await Get.offAllNamed<void>(AppRoutes.login);
  }
}
