import 'package:the_general_electric_stores_mobile/core/utils/formatters.dart';

/// A user as the API returns it.
///
/// Field names follow the API's snake_case exactly; the only translation is
/// into Dart naming. `_id` is read as `id` because that is what Mongo sends.
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.phone,
    this.userType,
    this.avatarUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;

  /// What the person types on the sign-in screen.
  final String username;

  final String firstName;
  final String lastName;
  final String? phone;

  /// The role the API authorises against (`authorize_user_types`).
  final String? userType;

  final String? avatarUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Best available human label: real name, else username, else email.
  String get fullName {
    final String name = '$firstName $lastName'.trim();
    if (name.isNotEmpty) return name;
    if (username.isNotEmpty) return username;
    return email;
  }

  String get initials => Formatters.initials(fullName);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      email: '${json['email'] ?? ''}',
      username: '${json['username'] ?? json['user_name'] ?? ''}',
      firstName: '${json['first_name'] ?? json['firstName'] ?? ''}',
      lastName: '${json['last_name'] ?? json['lastName'] ?? ''}',
      // The API's column is `phone_number` — that is the name the signin
      // payload carries (`auth_response.SIGNED_IN_USER_SELECT`).
      phone: json['phone_number']?.toString() ??
          json['phone']?.toString() ??
          json['mobile']?.toString(),
      userType: json['user_type']?.toString() ?? json['role']?.toString(),
      avatarUrl:
          json['avatar_url']?.toString() ?? json['profile_image']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: Formatters.parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: Formatters.parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        '_id': id,
        'email': email,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phone,
        'user_type': userType,
        'avatar_url': avatarUrl,
        'is_active': isActive,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  UserModel copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      username: username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      userType: userType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'UserModel($id, $email)';
}

/// What a successful login hands back: the tokens plus the user they belong to.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.user,
    this.refreshToken,
  });

  final String accessToken;
  final String? refreshToken;
  final UserModel user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final Object? nested = json['user'] ?? json['profile'];

    return AuthSession(
      accessToken: '${json['access_token'] ?? json['token'] ?? ''}',
      refreshToken: json['refresh_token']?.toString(),
      user: UserModel.fromJson(
        nested is Map<String, dynamic> ? nested : json,
      ),
    );
  }
}
