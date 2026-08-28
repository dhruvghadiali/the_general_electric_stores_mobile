import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/navigation/app_destination.dart';
import 'package:the_general_electric_stores_mobile/core/navigation/role_navigation.dart';
import 'package:the_general_electric_stores_mobile/core/services/auth_service.dart';

/// Keeps signed-out users out of the app.
///
/// These are routing guards, not security: the API authorises every request on
/// its own. They exist so a dead session shows the login screen instead of a
/// dashboard full of failed calls, and so one role cannot open another's screen
/// by deep link.
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) => AuthService.to.isLoggedIn
      ? null
      : const RouteSettings(name: AppRoutes.login);
}

/// The mirror image: keeps a signed-in user off the login page, and sends them
/// to their own shell rather than a fixed home route.
class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!AuthService.to.isLoggedIn) return null;
    final UserRole? role = AuthService.to.role.value;
    if (role == null) return null;
    return RouteSettings(name: AppRoutes.shellFor(role));
  }
}

/// Restricts a route to the roles that own the destination behind it.
///
/// Takes an [AppDestination] rather than a role list so the rule cannot drift
/// from `RoleNavigation` — a tab removed from a role becomes unreachable by
/// deep link in the same edit.
class DestinationMiddleware extends GetMiddleware {
  DestinationMiddleware(this.destination);

  final AppDestination destination;

  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final UserRole? role = AuthService.to.role.value;
    if (role == null) return const RouteSettings(name: AppRoutes.login);
    if (RoleNavigation.allows(role, destination)) return null;
    return RouteSettings(name: AppRoutes.shellFor(role));
  }
}

/// Guards a role's own shell route. A role can only enter its own.
class RoleMiddleware extends GetMiddleware {
  RoleMiddleware(this.allowed);

  final UserRole allowed;

  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final UserRole? role = AuthService.to.role.value;
    if (role == null) return const RouteSettings(name: AppRoutes.login);
    if (role == allowed) return null;
    return RouteSettings(name: AppRoutes.shellFor(role));
  }
}
