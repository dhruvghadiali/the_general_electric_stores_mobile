import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/navigation/app_destination.dart';

/// Which destinations each role has, and in what order.
///
/// This is the single source of truth for role separation in the UI. The shell
/// builds its bottom bar from it, [ShellBinding] registers controllers from it,
/// and `RoleMiddleware` refuses a route whose destination is not in the
/// signed-in role's list. Adding a tab to a role means editing this map and
/// nothing else.
///
/// Isolation is enforced here *and* on the API. This map stops a screen being
/// reached; it is not what keeps one role's data away from another — that is
/// the server's job, and the role-scoped endpoints exist so the server can do
/// it.
class RoleNavigation {
  const RoleNavigation._();

  static const Map<UserRole, List<AppDestination>> _destinations =
      <UserRole, List<AppDestination>>{
    UserRole.superAdmin: <AppDestination>[
      AppDestination.dashboard,
      AppDestination.products,
      AppDestination.contacts,
      AppDestination.settings,
    ],
    UserRole.employee: <AppDestination>[
      AppDestination.dashboard,
      AppDestination.products,
      AppDestination.contacts,
      AppDestination.settings,
    ],
    UserRole.warehouseManager: <AppDestination>[
      AppDestination.dashboard,
      AppDestination.stocks,
      AppDestination.settings,
    ],
  };

  static List<AppDestination> of(UserRole role) =>
      _destinations[role] ?? const <AppDestination>[];

  /// Whether this role may see this destination at all.
  static bool allows(UserRole role, AppDestination destination) =>
      of(role).contains(destination);
}
