import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';

/// Every path this app can call on the-general-electric-stores-api.
///
/// Paths are relative to [Env.apiBaseUrl] and never include the host. A screen
/// never builds a path inline.
///
/// **Everything is role-scoped.** `src/app.js` mounts one router per role, so
/// the role travels in the URL rather than in a body field or a header:
///
/// ```
/// app.use('/super-admin',       super_admin_router);
/// app.use('/warehouse-manager', warehouse_manager_router);
/// app.use('/employee',          employee_router);
/// ```
///
/// That is also what keeps one role's data away from another: every resource
/// router below the role calls `authorize_user_types(...)`, so a warehouse
/// manager's token presented at `/employee/products` is refused server-side,
/// and the client never builds that path because the role comes from the
/// session, not from what was tapped.
///
/// ## What each role's router actually mounts
///
/// Read off `src/routes/*/index.js`. A path that is not on this list does not
/// exist, and asking for it returns the API's HTML 404 page rather than a JSON
/// error — [not_found_handler] only answers in JSON below `/api/`.
///
/// | resource            | super-admin | employee                     | warehouse-manager |
/// |---------------------|-------------|------------------------------|-------------------|
/// | `/auth/signin`      | yes         | yes                          | yes               |
/// | `/dashboard`        | —           | `/purchase-credit` only      | —                 |
/// | `/products`         | list        | list, get, create, edit, del | —                 |
/// | `/companies`        | list        | list, get, create, edit, del | list              |
/// | `/company-contacts` | list        | list, create, edit, del      | —                 |
/// | `/company-addresses`| —           | create, edit, del            | —                 |
/// | `/purchases`        | list, get   | list, get, edit              | list, get, create, edit |
/// | `/sales`            | list        | list, get, create, edit, del | —                 |
/// | `/supplier-credits` | list        | full                         | —                 |
///
/// Three things the API does **not** have, which the app is written as though
/// it might: there is no `/signout`, no `/me` and no `/refresh-token` — the
/// signin JWT is the whole session and it expires on its own (`JWT_EXPIRES_IN`,
/// one day by default). And there is no `/stocks` router anywhere; a warehouse
/// manager's stock movements are filed as purchases.
class ApiEndpoints {
  const ApiEndpoints._();

  /// Prefixes any path with the signed-in role's router.
  static String scoped(UserRole role, String path) => '${role.pathPrefix}$path';

  // ------------------------------------------------------------------- auth
  //
  // Each role router mounts its auth router under `/auth`, and the signin
  // route inside that is `/signin`:
  //
  //   router.use('/auth', auth_router);   // routes/<role>/index.js
  //   router.post('/signin', ...);        // routes/<role>/auth/<role>_signin_route.js
  //
  // so the full path carries both segments. Dropping `/auth` is what produced
  // `404` on `POST /warehouse-manager/signin`.

  static String signIn(UserRole role) => scoped(role, '/auth/signin');

  /// Path suffixes that carry no bearer token, whatever role prefixes them.
  /// Matching on the suffix keeps this correct as roles are added.
  static const List<String> publicSuffixes = <String>['/auth/signin'];

  // --------------------------------------------------------------- products
  // Super admin lists; employee is the only role that can read one product or
  // write any. Warehouse manager has no product router at all.

  static String products(UserRole role) => scoped(role, '/products');

  static String product(UserRole role, String id) =>
      scoped(role, '/products/$id');

  // -------------------------------------------------------- company contacts
  // The API calls these company contacts, not contacts, and mounts them at
  // `/company-contacts`. There is no GET by id on any role's router — the list
  // is the only read — so [companyContact] is here for the writes.

  static String companyContacts(UserRole role) =>
      scoped(role, '/company-contacts');

  static String companyContact(UserRole role, String id) =>
      scoped(role, '/company-contacts/$id');

  // -------------------------------------------------------------- companies
  // Suppliers and customers. All three roles can list; only an employee can
  // read one or write any.

  static String companies(UserRole role) => scoped(role, '/companies');

  static String company(UserRole role, String id) =>
      scoped(role, '/companies/$id');

  // -------------------------------------------------------------- purchases
  // What a warehouse manager actually works with: a delivery is filed as a
  // purchase against a company. Creating one is warehouse-manager only.

  static String purchases(UserRole role) => scoped(role, '/purchases');

  static String purchase(UserRole role, String id) =>
      scoped(role, '/purchases/$id');

  // ------------------------------------------------------------------ sales

  static String sales(UserRole role) => scoped(role, '/sales');

  static String sale(UserRole role, String id) => scoped(role, '/sales/$id');

  // ------------------------------------------------------- supplier credits

  static String supplierCredits(UserRole role) =>
      scoped(role, '/supplier-credits');

  // ----------------------------------------------------------------- stocks
  //
  // **These do not exist on the API.** `src/app.js` mounts no stocks router
  // under any role, and `src/routes/warehouse_manager/index.js` mounts only
  // `/auth`, `/companies` and `/purchases`. Anything calling these gets the
  // API's 404 page.
  //
  // They are kept so the stocks feature compiles while the screens are decided
  // on. A warehouse manager's real subject is the purchase — a delivery filed
  // against a company — so the likely resolution is that the stocks feature
  // becomes the purchases feature and these two go away.

  static String stocks(UserRole role) => scoped(role, '/stocks');

  static String stock(UserRole role, String id) => scoped(role, '/stocks/$id');

  // -------------------------------------------------------------- dashboard
  //
  // One tile, one route, and only on the employee router:
  //
  //   GET /employee/dashboard/purchase-credit
  //
  // Super admin and warehouse manager mount no dashboard router, so this path
  // 404s for them. The dashboard feature has to ask per role rather than
  // assume every role has a summary endpoint.

  static String dashboardPurchaseCredit(UserRole role) =>
      scoped(role, '/dashboard/purchase-credit');

  /// Whether [role] has a dashboard endpoint to call at all.
  static bool hasDashboard(UserRole role) => role == UserRole.employee;
}
