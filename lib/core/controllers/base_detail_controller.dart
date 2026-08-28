import 'dart:async';

import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_exception.dart';
import 'package:the_general_electric_stores_mobile/core/services/auth_service.dart';

/// Loads one record by id for a detail screen.
///
/// The role comes from the session rather than the route, so a deep link
/// cannot ask for another role's copy of a record — the path is built from who
/// is signed in, not from what was tapped.
abstract class BaseDetailController<T> extends GetxController {
  final Rxn<T> item = Rxn<T>();
  final RxBool isLoading = false.obs;
  final Rxn<ApiException> failure = Rxn<ApiException>();

  String get id => Get.parameters['id'] ?? '';

  UserRole? get role => AuthService.to.role.value;

  /// The single fetch this screen needs.
  Future<T> fetch(UserRole role, String id);

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  Future<void> load() async {
    final UserRole? current = role;

    if (id.isEmpty || current == null) {
      failure.value = const ApiException(
        message: 'That record could not be opened.',
        statusCode: 404,
      );
      return;
    }

    isLoading.value = true;
    failure.value = null;

    try {
      item.value = await fetch(current, id);
    } on ApiException catch (error) {
      failure.value = error;
    } finally {
      isLoading.value = false;
    }
  }
}
