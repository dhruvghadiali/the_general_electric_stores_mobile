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
  // Scanning is four hops: what for, against whom, the list of what was read,
  // and the camera that fills it.
  static const String scanner = '/scan';
  static const String scanCompany = '/scan/company';
  static const String scanItems = '/scan/items';
  static const String scannerCamera = '/scan/camera';

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

  static String productDetailPath(String id) => '/products/${_segment(id)}';

  static String contactDetailPath(String id) => '/contacts/${_segment(id)}';

  static String stockDetailPath(String id) => '/stocks/${_segment(id)}';

  /// Turns a value from outside the app into exactly one path segment.
  ///
  /// The encoding is not tidiness, it is the difference between working and
  /// crashing. A scanned code is arbitrary text — it can hold `/`, `#`, `?`,
  /// spaces, anything a label printer felt like encoding — and interpolating
  /// it raw either invents extra path segments (`/stocks/site.com/x/42`) or
  /// produces characters outside the set GetX's `:id` pattern accepts.
  ///
  /// Either way GetX's `ParseRouteTree` matches the route on a *prefix* of the
  /// path and then runs its parameter regex against the *whole* path. That
  /// second match returns null, and the null-assert on the capture group kills
  /// the app inside `pushNamed`:
  ///
  /// ```
  /// Null check operator used on a null value
  ///   ParseRouteTree._parseParams (parse_route.dart:173)
  ///   ParseRouteTree.matchRoute
  ///   PageRedirect.needRecheck
  /// ```
  ///
  /// Nothing in that trace mentions a scanner, which is what makes it worth
  /// the comment.
  ///
  /// [Uri.encodeComponent] only ever emits characters the pattern accepts, and
  /// GetX decodes the segment again on the way into `Get.parameters`, so the
  /// detail controller still receives the original string.
  static String _segment(String value) => Uri.encodeComponent(value.trim());
}
