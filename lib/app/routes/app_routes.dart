import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';

/// Route names. Nothing navigates with a string literal.
///
/// Each role has its own shell route. They are separate routes rather than one
/// `/home` with a role switch inside, so a guard can refuse at the door: an
/// employee asking for `/super-admin` is turned away by the router, not by a
/// widget that decided to render nothing.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';

  // Role shells
  static const String superAdmin = '/super-admin';
  static const String employee = '/employee';
  static const String warehouseManager = '/warehouse-manager';

  // Detail routes, reached from inside a shell
  static const String productDetail = '/products/:id';
  static const String contactDetail = '/contacts/:id';
  static const String stockDetail = '/stocks/:id';

  /// The shell a role belongs in. The only place role maps to route.
  static String shellFor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return superAdmin;
      case UserRole.employee:
        return employee;
      case UserRole.warehouseManager:
        return warehouseManager;
    }
  }

  static String productDetailPath(String id) => '/products/$id';

  static String contactDetailPath(String id) => '/contacts/$id';

  static String stockDetailPath(String id) => '/stocks/$id';
}
