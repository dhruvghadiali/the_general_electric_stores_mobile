import 'package:flutter/material.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';

/// A labelled dropdown that matches [AppTextField] — same label placement,
/// same border, same error behaviour — so a form built from both reads as one
/// control repeated, not two widgets glued together.
///
/// [serverError] follows the same rule as the text field: a message the API
/// sent for this field stays visible until the user changes the selection, so
/// a local rule cannot quietly overwrite what the server said.
class AppDropdownField<T> extends StatefulWidget {
  const AppDropdownField({
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.value,
    required this.onChanged,
    super.key,
    this.hint,
    this.helper,
    this.serverError,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  });

  final String label;
  final List<T> items;
  final String Function(T item) itemLabel;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final String? helper;
  final String? serverError;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final bool enabled;

  @override
  State<AppDropdownField<T>> createState() => _AppDropdownFieldState<T>();
}

class _AppDropdownFieldState<T> extends State<AppDropdownField<T>> {
  bool _dirty = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? serverError = _dirty ? null : widget.serverError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(widget.label, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppDimens.sm),
        DropdownButtonFormField<T>(
          value: widget.value,
          isExpanded: true,
          validator: (T? value) => serverError ?? widget.validator?.call(value),
          onChanged: widget.enabled
              ? (T? value) {
                  if (!_dirty && widget.serverError != null) {
                    setState(() => _dirty = true);
                  }
                  widget.onChanged(value);
                }
              : null,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          dropdownColor: theme.colorScheme.surface,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          hint: widget.hint == null ? null : Text(widget.hint!),
          decoration: InputDecoration(
            helperText: widget.helper,
            errorText: serverError,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, size: AppDimens.iconMd),
          ),
          items: widget.items
              .map(
                (T item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    widget.itemLabel(item),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}
