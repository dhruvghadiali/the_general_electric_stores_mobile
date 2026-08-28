import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/utils/validators.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/app_button.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/app_dropdown_field.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/app_text_field.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/brand_logo.dart';
import 'package:the_general_electric_stores_mobile/features/auth/controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.screenPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimens.maxContentWidth,
              ),
              child: Form(
                key: controller.formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: AppDimens.xxl),
                      const BrandLogo(
                        maxWidth: 160,
                        widthFactor: 0.46,
                        heightFactor: 0.10,
                      ),
                      const SizedBox(height: AppDimens.lg),
                      Text(
                        'Sign in to continue',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppDimens.xxl),
                      Obx(
                        () => AppTextField(
                          label: 'Username',
                          controller: controller.usernameController,
                          hint: 'Your username',
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.person_outline,
                          validator: Validators.username,
                          serverError: controller.fieldErrors['username'],
                          autofillHints: const <String>[
                            AutofillHints.username,
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimens.lg),
                      Obx(
                        () => AppTextField(
                          label: 'Password',
                          controller: controller.passwordController,
                          hint: 'Your password',
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.lock_outline,
                          validator: (String? value) =>
                              Validators.required(value, field: 'Password'),
                          serverError: controller.fieldErrors['password'],
                          autofillHints: const <String>[
                            AutofillHints.password,
                          ],
                          onSubmitted: (_) => controller.submit(),
                        ),
                      ),
                      const SizedBox(height: AppDimens.lg),
                      Obx(
                        () => AppDropdownField<UserRole>(
                          label: 'Sign in as',
                          hint: 'Choose your role',
                          prefixIcon: Icons.badge_outlined,
                          items: controller.roleOptions,
                          itemLabel: (UserRole role) => role.label,
                          value: controller.role.value,
                          onChanged: controller.selectRole,
                          validator: (UserRole? value) => value == null
                              ? 'Choose how you are signing in.'
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppDimens.xl),
                      Obx(
                        () => AppButton(
                          label: 'Sign in',
                          onPressed: controller.submit,
                          isLoading: controller.isSubmitting.value,
                        ),
                      ),
                      const SizedBox(height: AppDimens.xl),
                      Text(
                        'Accounts are created by The General Electric Stores. '
                        'Contact your administrator if you need access.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
