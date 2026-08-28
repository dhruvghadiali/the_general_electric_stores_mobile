/// The roles a person can sign in as.
///
/// [value] is what goes on the wire and must match the API's `user_type` enum
/// exactly — the same strings `authorize_user_types` checks on every guarded
/// route. [label] is what a human reads and is never sent anywhere.
enum UserRole {
  superAdmin('super_admin', 'Super admin', '/super-admin'),
  employee('employee', 'Employee', '/employee'),
  warehouseManager('warehouse_manager', 'Warehouse manager', '/warehouse-manager');

  const UserRole(this.value, this.label, this.pathPrefix);

  final String value;
  final String label;

  /// The API mounts a router per role, so the role is part of the URL rather
  /// than the request body: `POST /employee/signin`.
  ///
  /// The segments are kebab-case and do **not** match [value], which is
  /// snake_case: `super_admin` signs in at `/super-admin`, and
  /// `warehouse_manager` at `/warehouse-manager`. Two spellings of the same
  /// idea, both real — [value] is what the API's `user_type` field holds,
  /// this is what its router is mounted at.
  final String pathPrefix;

  /// The order the sign-in dropdown offers them in.
  static const List<UserRole> signInOptions = <UserRole>[
    superAdmin,
    employee,
    warehouseManager,
  ];

  /// Reads a `user_type` off an API payload. Returns null for anything
  /// unrecognised rather than throwing — a role added server-side should not
  /// crash a client that predates it.
  static UserRole? fromValue(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final UserRole role in UserRole.values) {
      if (role.value == value) return role;
    }
    return null;
  }
}
