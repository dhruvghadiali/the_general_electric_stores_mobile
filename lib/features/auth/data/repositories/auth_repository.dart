import 'package:the_general_electric_stores_mobile/core/constants/api_endpoints.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_client.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_response.dart';
import 'package:the_general_electric_stores_mobile/features/auth/data/models/user_model.dart';

/// Every auth call the app can make — which is one.
///
/// The API mounts an auth router per role, so this takes a [UserRole] and
/// builds a role-scoped path from it: `POST /employee/auth/signin`. The role is
/// never a body field.
///
/// There is deliberately no `me`, `signOut` or refresh here, because the API
/// has no route for any of them. The signin JWT *is* the session: it carries
/// the user type, expires on its own (`JWT_EXPIRES_IN`, a day by default), and
/// nothing server-side can be asked to confirm, renew or revoke it. Signing out
/// is therefore a local act, and a restored session is trusted until a request
/// comes back 401.
///
/// A repository owns the endpoint, the request body and the parse. Controllers
/// receive models, never raw JSON, and never see [ApiClient].
class AuthRepository {
  const AuthRepository(this._api);

  final ApiClient _api;

  Future<AuthSession> signIn({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    final ApiResponse<AuthSession> response = await _api.post<AuthSession>(
      ApiEndpoints.signIn(role),
      body: <String, dynamic>{'username': username, 'password': password},
      parser: _session,
    );
    return response.data!;
  }

  AuthSession _session(Object? data) =>
      AuthSession.fromJson(firstObject(data));
}
