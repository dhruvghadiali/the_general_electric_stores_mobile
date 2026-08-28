import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_exception.dart';
import 'package:the_general_electric_stores_mobile/core/services/auth_service.dart';
import 'package:the_general_electric_stores_mobile/core/utils/app_snackbar.dart';
import 'package:the_general_electric_stores_mobile/features/auth/data/models/user_model.dart';
import 'package:the_general_electric_stores_mobile/features/auth/data/repositories/auth_repository.dart';

class LoginController extends GetxController {
  LoginController(this._repository);

  final AuthRepository _repository;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// Which role the credentials are presented for. The API decides whether
  /// they actually hold it — this only says which door was knocked on.
  final Rxn<UserRole> role = Rxn<UserRole>();

  final RxBool isSubmitting = false.obs;

  /// Field messages the API sent back, keyed by the API's field name.
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  List<UserRole> get roleOptions => UserRole.signInOptions;

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void selectRole(UserRole? value) => role.value = value;

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final UserRole? selected = role.value;
    if (selected == null) return;

    isSubmitting.value = true;
    fieldErrors.clear();

    try {
      final AuthSession session = await _repository.signIn(
        username: usernameController.text.trim(),
        password: passwordController.text,
        role: selected,
      );

      await AuthService.to.saveSession(session, selected);
      await Get.offAllNamed<void>(AppRoutes.shellFor(selected));
    } on ApiException catch (error) {
      if (error.isValidation && error.errors.isNotEmpty) {
        fieldErrors.assignAll(error.errors);
        formKey.currentState?.validate();
      }
      AppSnackbar.error(error.message, title: 'Could not sign in');
    } finally {
      isSubmitting.value = false;
    }
  }
}
