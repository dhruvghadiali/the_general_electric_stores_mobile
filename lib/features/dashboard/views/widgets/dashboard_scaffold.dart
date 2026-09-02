import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/services/auth_service.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/state_views.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/controllers/base_dashboard_controller.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/views/widgets/summary_unavailable.dart';

/// The frame the three dashboards share: greeting, loading and error handling,
/// pull-to-refresh. The tiles inside are each role's own.
class DashboardScaffold extends StatelessWidget {
  const DashboardScaffold({
    required this.controller,
    required this.children,
    super.key,
  });

  final BaseDashboardController controller;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            AuthService.to.user.value?.fullName.toUpperCase() ?? '-',
            style: theme.textTheme.headlineSmall,
          ),
        ),
      ),
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
                if (controller.hasFailed) ...<Widget>[
                  SummaryUnavailable(
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
}
