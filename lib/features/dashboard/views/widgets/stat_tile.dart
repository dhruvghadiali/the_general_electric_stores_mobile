import 'package:flutter/material.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/utils/formatters.dart';

/// One figure on a dashboard.
///
/// A missing value shows an em dash rather than a zero: "we have not been told"
/// and "there are none" are different facts, and a dashboard that conflates
/// them is worse than one that admits the gap.
class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.value,
    super.key,
    this.icon,
    this.tone,
    this.onTap,
  });

  final String label;
  final num? value;
  final IconData? icon;
  final Color? tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = tone ?? theme.colorScheme.primary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: AppDimens.iconLg, color: accent),
                const SizedBox(height: AppDimens.md),
              ],
              Text(
                value == null ? '—' : Formatters.quantity(value),
                style: theme.textTheme.headlineMedium?.copyWith(color: accent),
              ),
              const SizedBox(height: AppDimens.xxs),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The two-column grid the dashboards lay their tiles out in.
class StatGrid extends StatelessWidget {
  const StatGrid({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppDimens.md,
      mainAxisSpacing: AppDimens.md,
      childAspectRatio: 1.35,
      children: children,
    );
  }
}
