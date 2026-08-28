import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/services/auth_service.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/state_views.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/controllers/base_dashboard_controller.dart';

/// The frame the three dashboards share: greeting, loading and error handling,
/// pull-to-refresh. The tiles inside are each role's own.
class DashboardScaffold extends StatelessWidget {
  const DashboardScaffold({
    required this.controller,
    required this.title,
    required this.children,
    super.key,
  });

  final BaseDashboardController controller;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingView();
          }

          return RefreshIndicator(
            onRefresh: controller.refreshSummary,
            child: ListView(
              padding: const EdgeInsets.all(AppDimens.screenPadding),
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                Text(_greeting, style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppDimens.xxs),
                Obx(
                  () => Text(
                    AuthService.to.user.value?.fullName ?? 'there',
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: AppDimens.xl),
                if (controller.hasFailed) ...<Widget>[
                  _SummaryUnavailable(
                    message: controller.failure.value!.message,
                    onRetry: controller.load,
                  ),
                  const SizedBox(height: AppDimens.lg),
                ],
                ...children,
              ],
            ),
          );
        }),
      ),
    );
  }

  static String get _greeting {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

/// The summary failing is not the whole screen failing — the tiles below still
/// render, showing dashes, and the rest of the shell keeps working.
class _SummaryUnavailable extends StatelessWidget {
  const _SummaryUnavailable({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: AppDimens.iconMd,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: AppDimens.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
