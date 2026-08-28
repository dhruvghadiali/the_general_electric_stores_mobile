import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/services/auth_service.dart';
import 'package:the_general_electric_stores_mobile/core/utils/formatters.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/app_button.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/state_views.dart';
import 'package:the_general_electric_stores_mobile/features/auth/data/models/user_model.dart';
import 'package:the_general_electric_stores_mobile/features/settings/controllers/settings_controller.dart';

/// The one screen all three roles share.
///
/// It shows who is signed in, under which role, and lets them leave. Nothing
/// here is role-specific, which is why it is not forked — a role's *settings*
/// differ only when there is something to set, and there is not yet.
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Obx(() {
          final UserModel? user = AuthService.to.user.value;
          if (user == null) {
            return const EmptyView(
              icon: Icons.person_off_outlined,
              title: 'Not signed in',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppDimens.screenPadding),
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      user.initials,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user.fullName,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppDimens.xxs),
                        Text(
                          controller.role.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.xl),
              const Divider(),
              _Row(
                label: 'Username',
                value: user.username.isEmpty ? '—' : user.username,
              ),
              _Row(
                label: 'Email',
                value: user.email.isEmpty ? '—' : user.email,
              ),
              _Row(label: 'Mobile', value: user.phone ?? '—'),
              _Row(
                label: 'Role',
                value: UserRole.fromValue(user.userType)?.label ??
                    controller.role.label,
              ),
              _Row(
                label: 'Member since',
                value: Formatters.date(user.createdAt),
              ),
              const Divider(),
              const SizedBox(height: AppDimens.xxl),
              AppButton(
                label: 'Sign out',
                icon: Icons.logout_rounded,
                variant: AppButtonVariant.outlined,
                onPressed: () => _confirmSignOut(context),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    Get.dialog<void>(
      AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again on this device.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back<void>();
              controller.signOut();
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
