import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_exception.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/searchable_dropdown_field/searchable_dropdown_sheet.dart';

/// A dropdown whose list is fetched, and searched, by the server.
///
/// It reads like `AppDropdownField` and behaves differently in the one way that
/// matters: the options are not a fixed list this widget holds, they are
/// whatever the last request returned. That rules out
/// `DropdownButtonFormField`, which asserts its value is present in its items —
/// true of a local list, and false the moment a search narrows the options away
/// from the row the user already chose. Here the selection is drawn from
/// [value] alone, so a search can filter the list to nothing without unchoosing
/// anything.
///
/// A selection can also be undone: the field grows a clear button once
/// something is chosen, and the chosen row inside the sheet toggles off when
/// tapped again. Both report `null` through [onChanged], which is what lets a
/// dependent field — a product that belongs to a supplier — reset itself when
/// the thing it depended on goes away.
///
/// Typing is reported through [onSearch] on every keystroke; the *caller*
/// decides when that becomes a request. Debouncing belongs there because only
/// the caller knows what a request costs and what should happen to the state
/// around it.
class SearchableDropdownField<T> extends StatelessWidget {
  const SearchableDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    required this.onSearch,
    required this.isLoading,
    super.key,
    this.error,
    this.query = '',
    this.hint,
    this.searchHint,
    this.emptyMessage = 'Nothing matched that search.',
    this.itemSubtitle,
    this.prefixIcon,
    this.enabled = true,
    this.onRetry,
  });

  final String label;
  final T? value;

  /// The options as they stand — reactive, because the sheet is open while the
  /// request that fills it is still running.
  final RxList<T> items;
  final RxBool isLoading;
  final Rxn<ApiException>? error;

  final String Function(T item) itemLabel;

  /// A second line under each row: a product code, a company's type.
  final String? Function(T item)? itemSubtitle;

  final ValueChanged<T?> onChanged;

  /// Called on every keystroke in the search box. Debounce it.
  final ValueChanged<String> onSearch;

  /// The term the search box opens with, so reopening the sheet does not lose
  /// what was typed.
  final String query;

  final String? hint;
  final String? searchHint;
  final String emptyMessage;
  final IconData? prefixIcon;
  final bool enabled;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final T? current = value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppDimens.sm),
        InkWell(
          onTap: enabled ? () => _open(context) : null,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          child: InputDecorator(
            isEmpty: current == null,
            decoration: InputDecoration(
              hintText: hint,
              enabled: enabled,
              prefixIcon:
                  prefixIcon == null ? null : Icon(prefixIcon, size: AppDimens.iconMd),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (current != null && enabled)
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Clear $label',
                      // Straight to null: clearing is not a trip through the
                      // sheet, and a dependent field is waiting on this.
                      onPressed: () => onChanged(null),
                    ),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
            child: current == null
                ? null
                : Text(
                    itemLabel(current),
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: enabled
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _open(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SearchableDropdownSheet<T>(
        title: label,
        searchHint: searchHint ?? 'Search $label'.toLowerCase(),
        initialQuery: query,
        onQueryChanged: onSearch,
        items: items,
        isLoading: isLoading,
        error: error,
        selected: value,
        itemLabel: itemLabel,
        itemSubtitle: itemSubtitle,
        emptyMessage: emptyMessage,
        onRetry: onRetry,
        // Null arrives when the chosen row is tapped again, or the sheet's own
        // clear row is used.
        onSelected: (T? item) {
          onChanged(item);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }
}
