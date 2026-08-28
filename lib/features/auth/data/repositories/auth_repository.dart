import 'package:the_general_electric_stores_mobile/core/constants/api_endpoints.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_client.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_response.dart';
import 'package:the_general_electric_stores_mobile/features/auth/data/models/user_model.dart';

/// Every auth call the app can make.
///
/// The API mounts auth per role, so every method here takes a [UserRole] and
/// builds a role-scoped path from it — `POST /employee/signin`. The role
/// is never a body field.
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

  Future<UserModel> me(UserRole role) async {
    final ApiResponse<UserModel> response = await _api.get<UserModel>(
      ApiEndpoints.me(role),
      parser: (Object? data) => UserModel.fromJson(firstObject(data)),
    );
    return response.data!;
  }

  /// Best-effort — the local session is cleared whether or not this succeeds.
  Future<void> signOut(UserRole role) =>
      _api.post<void>(ApiEndpoints.signOut(role));

  AuthSession _session(Object? data) =>
      AuthSession.fromJson(firstObject(data));
}
