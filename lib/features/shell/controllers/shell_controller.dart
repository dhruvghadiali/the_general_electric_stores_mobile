import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/navigation/app_destination.dart';
import 'package:the_general_electric_stores_mobile/core/navigation/role_navigation.dart';

/// Holds which tab of a role's shell is showing.
///
/// The role is fixed at construction by the binding for that shell, not read
/// from the session at every rebuild — a shell is for one role for its whole
/// life, and saying so here means no screen has to re-check.
class ShellController extends GetxController {
  ShellController(this.role);

  final UserRole role;

  final RxInt index = 0.obs;

  List<AppDestination> get destinations => RoleNavigation.of(role);

  AppDestination get current => destinations[index.value];

  void select(int value) {
    if (value < 0 || value >= destinations.length) return;
    index.value = value;
  }

  /// Jumps to a destination by name — used when a dashboard card links to
  /// another tab. A destination this role does not have is a no-op.
  void goTo(AppDestination destination) {
    final int position = destinations.indexOf(destination);
    if (position != -1) index.value = position;
  }
}
