import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/utils/app_snackbar.dart';
import 'package:the_general_electric_stores_mobile/core/utils/formatters.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/app_button.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/scanned_items_controller.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/data/models/scan_purpose.dart';

/// Everything read so far, newest first.
///
/// The list is the point of the screen, so it gets the room: the context strip
/// says what is being scanned and against whom in one line, and the two actions
/// sit at the bottom where a thumb reaches them.
class ScannedItemsView extends GetView<ScannedItemsController> {
  const ScannedItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Leaving by the back gesture must mean the same as tapping Done, or a
      // pallet's worth of scanning disappears on a stray swipe.
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) controller.done();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scanned codes'),
          leading: IconButton(
            onPressed: controller.done,
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
          ),
          actions: <Widget>[
            Obx(
              () => controller.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      onPressed: () => _confirmClear(context),
                      icon: const Icon(Icons.delete_sweep_outlined),
                      tooltip: 'Clear all',
                    ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _ContextStrip(controller: controller),
              Expanded(
                child: Obx(() {
                  if (controller.isEmpty) {
                    return _NothingYet(isScanning: controller.isScanning.value);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppDimens.screenPadding),
                    itemCount: controller.items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppDimens.sm),
                    itemBuilder: (BuildContext context, int index) {
                      final ScannedItem item = controller.items[index];
                      return _ScannedRow(
                        item: item,
                        // Newest first, so the top row is the highest number.
                        position: controller.items.length - index,
                        repeats: controller.occurrencesOf(item.code),
                        onRemove: () => controller.removeAt(index),
                      );
                    },
                  );
                }),
              ),
              _Actions(controller: controller),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final bool? confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear every code?'),
        content: Text(
          'This removes all ${controller.items.length} readings. It cannot be '
          'undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back<bool>(result: false),
            child: const Text('Keep them'),
          ),
          TextButton(
            onPressed: () => Get.back<bool>(result: true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) controller.clear();
  }
}

/// What is being scanned, and against whom. Both were chosen two screens ago
/// and are easy to have stopped thinking about by the tenth carton.
class _ContextStrip extends StatelessWidget {
  const _ContextStrip({required this.controller});

  final ScannedItemsController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: theme.colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.screenPadding,
        vertical: AppDimens.md,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  controller.purpose.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                Text(
                  controller.company?.name ?? '—',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.sm),
          // The counts are read *here*, inside the builder, and passed down as
          // plain numbers.
          //
          // `Obx(() => _CountChip(controller: controller))` would read nothing
          // reactive — the observables would be touched inside the child's own
          // `build`, which runs outside this scope. GetX detects that and
          // throws `ObxError`, Flutter swaps in an `ErrorWidget`, and a
          // `RenderErrorBox` sizes itself to 100000×100000. That is where the
          // "overflowed by 99641 pixels" came from: 99641 + 359px of row = the
          // error box, not the layout.
          Obx(
            () => _CountChip(
              total: controller.items.length,
              distinct: controller.distinctCount,
            ),
          ),
        ],
      ),
    );
  }
}

/// Readings, and distinct codes when the two differ.
///
/// They differ exactly when something was scanned twice, which is the one
/// number worth surfacing without being asked.
class _CountChip extends StatelessWidget {
  const _CountChip({required this.total, required this.distinct});

  /// Plain numbers, not the controller. Whatever is reactive has to be read by
  /// the `Obx` that rebuilds this, not by this widget.
  final int total;
  final int distinct;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.md,
        vertical: AppDimens.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(
        total == distinct ? '$total' : '$total · $distinct unique',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

/// One reading.
class _ScannedRow extends StatelessWidget {
  const _ScannedRow({
    required this.item,
    required this.position,
    required this.repeats,
    required this.onRemove,
  });

  final ScannedItem item;
  final int position;
  final int repeats;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Dismissible(
      key: ValueKey<String>('${item.code}-${item.scannedAt.microsecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimens.xl),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Text(
                  '$position',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Monospaced: a scanned code is read character by
                    // character when someone is checking it against a label,
                    // and proportional digits make that harder than it needs
                    // to be.
                    //
                    // `Text` with a line limit rather than `SelectableText`,
                    // which has no overflow handling at all — a long code with
                    // no spaces in it (a PDF417 carries plenty) would run past
                    // the row and overflow the flex. The copy button is what
                    // gets the whole value out.
                    Text(
                      item.code,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontFamilyFallback: const <String>[
                          'Menlo',
                          'Courier New',
                          'Courier',
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.xs),
                    Wrap(
                      spacing: AppDimens.sm,
                      runSpacing: AppDimens.xxs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        _Tag(
                          label: item.symbologyLabel,
                          tone: item.isProductBarcode
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.primary,
                        ),
                        Text(
                          Formatters.dateTime(item.scannedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (repeats > 1)
                          _Tag(
                            label: 'read $repeats×',
                            tone: theme.colorScheme.error,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: item.code));
                  AppSnackbar.success('Code copied.', title: 'Copied');
                },
                icon: const Icon(Icons.copy_rounded, size: AppDimens.iconMd),
                tooltip: 'Copy code',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.sm,
        vertical: AppDimens.xxs,
      ),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: tone, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _NothingYet extends StatelessWidget {
  const _NothingYet({required this.isScanning});

  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.qr_code_scanner_rounded,
              size: AppDimens.xxxl,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppDimens.lg),
            Text(
              isScanning ? 'Opening the camera…' : 'Nothing scanned yet',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.sm),
            Text(
              'Codes you read will be listed here, newest first.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.controller});

  final ScannedItemsController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      child: Row(
        children: <Widget>[
          Expanded(
            child: AppButton(
              label: 'Scan another',
              icon: Icons.qr_code_scanner_rounded,
              variant: AppButtonVariant.outlined,
              onPressed: controller.scanAnother,
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Obx(
              () => AppButton(
                label: 'Done',
                onPressed: controller.done,
                isEnabled: !controller.isEmpty,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
