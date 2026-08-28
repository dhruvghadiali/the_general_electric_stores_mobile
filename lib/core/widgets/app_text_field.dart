import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';

/// A labelled text field with the app's spacing and validation behaviour.
///
/// [serverError] is separate from [validator] on purpose: a message the API
/// sent back for this field is shown until the user edits the field, so a
/// local rule can never quietly overwrite what the server said.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.label,
    super.key,
    this.controller,
    this.hint,
    this.helper,
    this.serverError,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffix,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofillHints,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final String? serverError;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final List<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;
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
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          validator: (String? value) =>
              serverError ?? widget.validator?.call(value),
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscured,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: _obscured ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          autofillHints: widget.autofillHints,
          onChanged: (String value) {
            if (!_dirty && widget.serverError != null) {
              setState(() => _dirty = true);
            }
            widget.onChanged?.call(value);
          },
          onFieldSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helper,
            errorText: serverError,
            counterText: '',
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, size: AppDimens.iconMd),
            suffixIcon: _suffix(),
          ),
        ),
      ],
    );
  }

  Widget? _suffix() {
    if (widget.obscureText) {
      return IconButton(
        onPressed: () => setState(() => _obscured = !_obscured),
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: AppDimens.iconMd,
        ),
        tooltip: _obscured ? 'Show password' : 'Hide password',
      );
    }
    return widget.suffix;
  }
}
