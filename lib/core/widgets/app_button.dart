import 'package:flutter/material.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';

enum AppButtonVariant { filled, outlined, text }

/// The app's button.
///
/// It owns one thing the raw Material buttons do not: a [isLoading] state that
/// swaps the label for a spinner *and* blocks the tap, so a double-submit
/// cannot create two orders.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.filled,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? handler =
        (!isEnabled || isLoading) ? null : onPressed;
    final Widget child = isLoading ? _spinner(context) : _label();

    final Widget button = switch (variant) {
      AppButtonVariant.filled =>
        ElevatedButton(onPressed: handler, child: child),
      AppButtonVariant.outlined =>
        OutlinedButton(onPressed: handler, child: child),
      AppButtonVariant.text => TextButton(onPressed: handler, child: child),
    };

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _label() {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: AppDimens.iconMd),
        const SizedBox(width: AppDimens.sm),
        Text(label),
      ],
    );
  }

  Widget _spinner(BuildContext context) {
    final Color color = variant == AppButtonVariant.filled
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: AppDimens.iconMd,
      width: AppDimens.iconMd,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }
}
