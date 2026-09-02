import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/app_dropdown_field.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/state_views.dart';
import 'package:the_general_electric_stores_mobile/features/companies/data/models/company_model.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/purchase_stock_controller.dart';

/// Where "Purchase stock" lands: items arriving into the warehouse.
///
/// The supplier is asked for first because it is the one fact that scopes
/// everything after it — the list comes from the API already filtered to
/// `company_type=supplier`, so nothing a customer-only company owns can be
/// picked here by mistake.
class PurchaseStockView extends GetView<PurchaseStockController> {
  const PurchaseStockView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase stock'),
        leading: IconButton(
          onPressed: controller.cancel,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingView(message: 'Loading suppliers…');
          }

          if (controller.failure.value != null) {
            return ErrorView(
              error: controller.failure.value!,
              onRetry: controller.load,
            );
          }

          if (controller.suppliers.isEmpty) {
            return EmptyView(
              icon: Icons.domain_disabled_outlined,
              title: 'No suppliers yet',
              message: 'There is nobody to book this stock in against.',
              actionLabel: 'Try again',
              onAction: controller.load,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppDimens.screenPadding),
            children: <Widget>[
              Obx(
                () => AppDropdownField<CompanyModel>(
                  label: 'Supplier',
                  hint: 'Choose a supplier',
                  prefixIcon: Icons.domain_outlined,
                  items: controller.suppliers,
                  itemLabel: (CompanyModel company) => company.name,
                  value: controller.selected.value,
                  onChanged: controller.select,
                  validator: (CompanyModel? value) =>
                      value == null ? 'Choose a supplier.' : null,
                ),
              ),
              Obx(
                () => controller.isTruncated.value
                    ? Padding(
                        padding: const EdgeInsets.only(top: AppDimens.sm),
                        child: Text(
                          'Not every supplier is listed — there are more than '
                          'this picker can load. Search is needed.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        }),
      ),
    );
  }
}
