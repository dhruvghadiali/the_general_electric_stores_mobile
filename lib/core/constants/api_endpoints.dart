import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';

/// Every path this app can call on the-general-electric-stores-api.
///
/// Paths are relative to [Env.apiBaseUrl] and never include the host. A screen
/// never builds a path inline.
///
/// **Everything is role-scoped.** The API mounts a router per role, so the role
/// travels in the URL rather than in a body field or a header:
///
/// ```
/// POST /super-admin/signin
/// POST /employee/signin
/// POST /warehouse-manager/signin       body: { username, password }
/// ```
///
/// That is also what keeps one role's data away from another: a warehouse
/// manager's token presented at `/employee/products` is the server's call to
/// refuse, and the client never builds that path because the role comes from
/// the session, not from what was tapped.
///
/// Nothing below is confirmed against the running SIT server — the sign-in
/// paths come from the API team, the rest follow the same shape by assumption.
/// Correct a path here and nothing else in the app has to change.
class ApiEndpoints {
  const ApiEndpoints._();

  /// Prefixes any path with the signed-in role's router.
  static String scoped(UserRole role, String path) => '${role.pathPrefix}$path';

  // ------------------------------------------------------------------- auth
  // No `/auth` segment: the role router mounts these directly.

  static String signIn(UserRole role) => scoped(role, '/signin');

  static String signOut(UserRole role) => scoped(role, '/signout');

  static String me(UserRole role) => scoped(role, '/me');

  static String refreshToken(UserRole role) => scoped(role, '/refresh-token');

  /// Path suffixes that carry no bearer token, whatever role prefixes them.
  /// Matching on the suffix keeps this correct as roles are added.
  static const List<String> publicSuffixes = <String>[
    '/signin',
    '/refresh-token',
  ];

  // --------------------------------------------------------------- products
  // Super admin and employee.

  static String products(UserRole role) => scoped(role, '/products');

  static String product(UserRole role, String id) =>
      scoped(role, '/products/$id');

  // --------------------------------------------------------------- contacts
  // Super admin and employee.

  static String contacts(UserRole role) => scoped(role, '/contacts');

  static String contact(UserRole role, String id) =>
      scoped(role, '/contacts/$id');

  // ----------------------------------------------------------------- stocks
  // Warehouse manager.

  static String stocks(UserRole role) => scoped(role, '/stocks');

  static String stock(UserRole role, String id) => scoped(role, '/stocks/$id');

  // ------------------------------------------------------------- dashboards
  // Each role's dashboard reads its own summary endpoint.

  static String dashboard(UserRole role) => scoped(role, '/dashboard');
}
