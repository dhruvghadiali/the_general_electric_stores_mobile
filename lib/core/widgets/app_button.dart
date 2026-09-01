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
    if (icon == null) {
      return Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    // `Flexible` around the text, not a bare `Text`.
    //
    // This row is `MainAxisSize.min`, so it asks for exactly icon + gap +
    // label. Put two of these side by side in a narrow row — "Scan another"
    // next to "Done" on a small phone — and the label wants more width than
    // the button was given, which a plain `Text` cannot give up. The result is
    // a RenderFlex overflow on the right at paint time.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: AppDimens.iconMd),
        const SizedBox(width: AppDimens.sm),
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
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
