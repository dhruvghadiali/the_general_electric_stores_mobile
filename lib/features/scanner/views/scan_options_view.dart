import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/constants/scan_purpose.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/scan_options_controller.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/widgets/purpose_card.dart';

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
        title: const Text('Scan Products'),
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
              PurposeCard(
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
