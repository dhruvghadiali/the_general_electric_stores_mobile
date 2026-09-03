import 'package:flutter/material.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';

/// The shape every [RequestStatusLine] state is drawn in: a leading icon or
/// spinner, a line of text in that state's colour, and an optional retry.
///
/// Split out so the three states cannot drift apart — the icon column, the
/// gap and the text style are decided once here rather than three times in
/// the widget that chooses between them.
class StatusLine extends StatelessWidget {
  const StatusLine({
    required this.leading,
    required this.text,
    required this.tone,
    super.key,
    this.onRetry,
  });

  final Widget leading;
  final String text;
  final Color tone;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.xxs),
            child: leading,
          ),
          const SizedBox(width: AppDimens.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(color: tone),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
