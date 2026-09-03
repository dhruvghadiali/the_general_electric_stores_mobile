import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_exception.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/request_status_line/request_status_line.dart';

/// The list a [SearchableDropdownField] opens: a search box, whatever the last
/// request returned, and a line reporting that request.
///
/// The status line sits directly under the search box rather than replacing the
/// list, so the rows already on screen stay readable while the next search is in
/// flight — a list that blanks on every keystroke is harder to use than one that
/// lags a moment behind.
///
/// [onSelected] carries null for an unselect: the chosen row toggles off when
/// tapped again, and a "Clear selection" row sits above the list while there is
/// something to clear.
class SearchableDropdownSheet<T> extends StatefulWidget {
  const SearchableDropdownSheet({
    required this.title,
    required this.searchHint,
    required this.initialQuery,
    required this.onQueryChanged,
    required this.items,
    required this.isLoading,
    required this.itemLabel,
    required this.onSelected,
    required this.emptyMessage,
    super.key,
    this.error,
    this.selected,
    this.itemSubtitle,
    this.onRetry,
  });

  final String title;
  final String searchHint;
  final String initialQuery;
  final ValueChanged<String> onQueryChanged;

  final RxList<T> items;
  final RxBool isLoading;
  final Rxn<ApiException>? error;

  final T? selected;
  final String Function(T item) itemLabel;
  final String? Function(T item)? itemSubtitle;
  final ValueChanged<T?> onSelected;
  final String emptyMessage;
  final VoidCallback? onRetry;

  @override
  State<SearchableDropdownSheet<T>> createState() =>
      _SearchableDropdownSheetState<T>();
}

class _SearchableDropdownSheetState<T>
    extends State<SearchableDropdownSheet<T>> {
  late final TextEditingController _search =
      TextEditingController(text: widget.initialQuery);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      // The keyboard is up the whole time this sheet is open.
      padding: EdgeInsets.only(
        left: AppDimens.screenPadding,
        right: AppDimens.screenPadding,
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppDimens.md),
            TextField(
              controller: _search,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (String term) {
                widget.onQueryChanged(term);
                // Only to redraw the clear button; the results come from the
                // caller's own request.
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Clear',
                        onPressed: () {
                          _search.clear();
                          widget.onQueryChanged('');
                          setState(() {});
                        },
                      ),
              ),
            ),
            Obx(
              () => RequestStatusLine(
                isLoading: widget.isLoading.value,
                loadingMessage: 'Searching…',
                error: widget.error?.value,
                onRetry: widget.onRetry,
                note: _note,
                noteIcon: Icons.search_off_rounded,
              ),
            ),
            const SizedBox(height: AppDimens.sm),
            if (widget.selected != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.close_rounded),
                title: const Text('Clear selection'),
                onTap: () => widget.onSelected(null),
              ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: widget.items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final T item = widget.items[index];
                    final String? subtitle = widget.itemSubtitle?.call(item);
                    final bool isSelected = item == widget.selected;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(widget.itemLabel(item)),
                      subtitle: subtitle == null ? null : Text(subtitle),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                      // Tapping what is already chosen unchooses it, so the
                      // same gesture both selects and clears.
                      onTap: () => widget.onSelected(isSelected ? null : item),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Only the empty result is worth a line of its own: everything else the list
  /// itself already shows.
  String? get _note {
    if (widget.isLoading.value || widget.error?.value != null) return null;
    return widget.items.isEmpty ? widget.emptyMessage : null;
  }
}
