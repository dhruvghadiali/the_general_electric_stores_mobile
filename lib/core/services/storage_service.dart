import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:the_general_electric_stores_mobile/core/constants/storage_keys.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';

/// The only place the app touches disk.
///
/// Tokens go to the keychain / keystore through [FlutterSecureStorage];
/// everything else goes to [SharedPreferences]. A caller picks the bucket by
/// picking the method, never by passing a flag.
class StorageService extends GetxService {
  static StorageService get to => Get.find<StorageService>();

  late final SharedPreferences _prefs;

  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ---------------------------------------------------------------- secure

  Future<String?> get accessToken => _secure.read(key: StorageKeys.accessToken);

  Future<String?> get refreshToken =>
      _secure.read(key: StorageKeys.refreshToken);

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _secure.write(key: StorageKeys.accessToken, value: accessToken);
    if (refreshToken != null) {
      await _secure.write(key: StorageKeys.refreshToken, value: refreshToken);
    }
  }

  Future<void> clearTokens() async {
    await _secure.delete(key: StorageKeys.accessToken);
    await _secure.delete(key: StorageKeys.refreshToken);
  }

  // ----------------------------------------------------------- preferences

  Map<String, dynamic>? readJson(String key) {
    final String? value = _prefs.getString(key);
    if (value == null || value.isEmpty) return null;
    final Object? decoded = jsonDecode(value);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  Future<bool> writeJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  Future<bool> remove(String key) => _prefs.remove(key);

  // ------------------------------------------------------------ signed-in role

  /// The role the session was opened under, used to build role-scoped auth
  /// paths. Kept out of secure storage on purpose — it is not a secret, and
  /// the interceptor needs it synchronously.
  UserRole? get signedInRole =>
      UserRole.fromValue(_prefs.getString(StorageKeys.userRole));

  Future<bool> saveSignedInRole(UserRole role) =>
      _prefs.setString(StorageKeys.userRole, role.value);

  /// Wipes the session — tokens and the cached user — but keeps device
  /// preferences such as theme and locale.
  Future<void> clearSession() async {
    await clearTokens();
    await _prefs.remove(StorageKeys.user);
    await _prefs.remove(StorageKeys.userRole);
  }
}
