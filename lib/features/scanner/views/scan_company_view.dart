import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/app_button.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/app_dropdown_field.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/state_views.dart';
import 'package:the_general_electric_stores_mobile/features/companies/data/models/company_model.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/scan_company_controller.dart';

/// Second step of a scan: which company is this for?
///
/// The chosen purpose is shown at the top rather than left behind on the
/// previous screen — by the time someone is picking a supplier it is easy to
/// have forgotten whether they tapped purchase or sales.
class ScanCompanyView extends GetView<ScanCompanyController> {
  const ScanCompanyView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select company'),
        leading: IconButton(
          onPressed: controller.cancel,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingView(message: 'Loading companies…');
          }

          if (controller.failure.value != null) {
            return ErrorView(
              error: controller.failure.value!,
              onRetry: controller.load,
            );
          }

          if (controller.companies.isEmpty) {
            return EmptyView(
              icon: Icons.domain_disabled_outlined,
              title: 'No companies yet',
              message: 'There is nothing to attribute this scan to.',
              actionLabel: 'Try again',
              onAction: controller.load,
            );
          }

          return Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppDimens.screenPadding),
                  children: <Widget>[
                    _PurposeStrip(controller: controller),
                    const SizedBox(height: AppDimens.xl),
                    Obx(
                      () => AppDropdownField<CompanyModel>(
                        label: 'Company',
                        hint: 'Choose a company',
                        prefixIcon: Icons.domain_outlined,
                        items: controller.companies,
                        itemLabel: (CompanyModel company) => company.name,
                        value: controller.selected.value,
                        onChanged: controller.select,
                        validator: (CompanyModel? value) =>
                            value == null ? 'Choose a company.' : null,
                      ),
                    ),
                    Obx(
                      () => controller.isTruncated.value
                          ? Padding(
                              padding: const EdgeInsets.only(top: AppDimens.sm),
                              child: Text(
                                'Not every company is listed — there are more '
                                'than this picker can load. Search is needed.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: AppDimens.lg),
                    Obx(
                      () =>
                          _SelectedCompany(company: controller.selected.value),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimens.screenPadding),
                child: Obx(
                  () => AppButton(
                    label: 'Continue to scan',
                    icon: Icons.qr_code_scanner_rounded,
                    onPressed: controller.continueToScan,
                    isEnabled: controller.canContinue,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// A reminder of what was chosen on the previous screen.
class _PurposeStrip extends StatelessWidget {
  const _PurposeStrip({required this.controller});

  final ScanCompanyController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            controller.purpose.icon,
            size: AppDimens.iconMd,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: AppDimens.sm),
          Expanded(
            child: Text(
              controller.purpose.label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// What was picked, spelled out. A dropdown showing one line of text is a thin
/// basis for a decision that ends in stock moving.
class _SelectedCompany extends StatelessWidget {
  const _SelectedCompany({required this.company});

  final CompanyModel? company;

  @override
  Widget build(BuildContext context) {
    final CompanyModel? value = company;
    if (value == null) return const SizedBox.shrink();

    final ThemeData theme = Theme.of(context);
    final CompanyAddress? address =
        value.addresses.isEmpty ? null : value.addresses.first;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    value.initials,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(value.name, style: theme.textTheme.titleSmall),
                      if (value.subtitle.isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppDimens.xxs),
                        Text(
                          value.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (address != null) ...<Widget>[
              const SizedBox(height: AppDimens.md),
              Text(
                address.fullAddress,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (value.gstNumber != null) ...<Widget>[
              const SizedBox(height: AppDimens.xs),
              Text(
                'GST ${value.gstNumber}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
