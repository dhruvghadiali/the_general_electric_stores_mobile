import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/scan_options_controller.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/data/models/scan_purpose.dart';

/// Asks what the scan is for before opening the camera.
///
/// Two large targets rather than a dropdown or a segmented control: this is
/// the first thing a warehouse hand does with gloves on, and the answer decides
/// what the scan means.
class ScanOptionsView extends GetView<ScanOptionsController> {
  const ScanOptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
        leading: IconButton(
          onPressed: controller.cancel,
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cancel',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          children: <Widget>[
            Text(
              'What are you scanning for?',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppDimens.xs),
            Text(
              'The camera opens once you choose.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimens.xl),
            for (final ScanPurpose purpose in ScanPurpose.values) ...<Widget>[
              _PurposeCard(
                purpose: purpose,
                onTap: () => controller.choose(purpose),
              ),
              const SizedBox(height: AppDimens.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _PurposeCard extends StatelessWidget {
  const _PurposeCard({required this.purpose, required this.onTap});

  final ScanPurpose purpose;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Row(
            children: <Widget>[
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Icon(
                  purpose.icon,
                  size: AppDimens.iconLg,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppDimens.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(purpose.label, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppDimens.xxs),
                    Text(
                      purpose.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
