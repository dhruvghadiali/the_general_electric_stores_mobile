import 'package:flutter/material.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_exception.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/request_status_line/status_line.dart';

/// A one-line report on a request, shown beside the control it fills.
///
/// The alternative — replacing the screen with a [LoadingView] while a list
/// loads — hides the very control the person came to use, and makes a failure
/// look like a broken screen rather than a field that has nothing in it yet.
/// Keeping the field on screen and putting its state underneath means the
/// layout never jumps, and "loading", "that failed" and "here is a caveat" all
/// arrive in the same place.
///
/// Precedence is loading, then failure, then [note]: a refresh already in
/// flight is more current than the error it is retrying.
class RequestStatusLine extends StatelessWidget {
  const RequestStatusLine({
    super.key,
    this.isLoading = false,
    this.loadingMessage,
    this.error,
    this.onRetry,
    this.note,
    this.noteIcon = Icons.info_outline_rounded,
    this.noteTone,
  });

  final bool isLoading;
  final String? loadingMessage;

  /// The failure to report, if the last attempt failed.
  final ApiException? error;

  /// Offered on a failure, and on a [note] that is worth retrying.
  final VoidCallback? onRetry;

  /// Anything else worth saying once the request has settled — an empty result,
  /// a truncated list, a count.
  final String? note;
  final IconData noteIcon;
  final Color? noteTone;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (isLoading) {
      return StatusLine(
        leading: SizedBox(
          height: AppDimens.iconSm,
          width: AppDimens.iconSm,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        ),
        text: loadingMessage ?? 'Loading…',
        tone: theme.colorScheme.onSurfaceVariant,
      );
    }

    final ApiException? failure = error;
    if (failure != null) {
      return StatusLine(
        leading: Icon(
          failure.isNetwork
              ? Icons.wifi_off_rounded
              : Icons.error_outline_rounded,
          size: AppDimens.iconSm,
          color: theme.colorScheme.error,
        ),
        text: failure.message,
        tone: theme.colorScheme.error,
        onRetry: onRetry,
      );
    }

    final String? message = note;
    if (message == null || message.isEmpty) return const SizedBox.shrink();

    return StatusLine(
      leading: Icon(
        noteIcon,
        size: AppDimens.iconSm,
        color: noteTone ?? theme.colorScheme.onSurfaceVariant,
      ),
      text: message,
      tone: noteTone ?? theme.colorScheme.onSurfaceVariant,
      onRetry: onRetry,
    );
  }
}
