import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/controllers/base_list_controller.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/state_views.dart';

/// The body of any screen backed by a [BaseListController].
///
/// It owns the four states (loading / failed / empty / content), pull-to-
/// refresh, infinite scroll and the end-of-list footer. Each role's screen
/// supplies its own app bar, its own actions and its own row widget, so the
/// screens stay separate while the paging behaviour stays identical.
class PagedListView<T> extends StatelessWidget {
  const PagedListView({
    required this.controller,
    required this.itemBuilder,
    required this.emptyTitle,
    super.key,
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.loadingMessage,
    this.totalLabel,
    this.padding = const EdgeInsets.all(AppDimens.screenPadding),
    this.header,
  });

  final BaseListController<T> controller;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String emptyTitle;
  final String? emptyMessage;
  final IconData emptyIcon;
  final String? loadingMessage;

  /// Word for the footer count, e.g. "products" in "128 products".
  final String? totalLabel;

  final EdgeInsets padding;

  /// Pinned above the list — filter chips, a summary strip.
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (header != null) header!,
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return LoadingView(message: loadingMessage);
            }

            if (controller.hasFailed) {
              return ErrorView(
                error: controller.failure.value!,
                onRetry: controller.load,
              );
            }

            if (controller.isEmpty) {
              return EmptyView(
                icon: emptyIcon,
                title: emptyTitle,
                message: emptyMessage,
                actionLabel: 'Clear filters',
                onAction: controller.clearFilters,
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refreshList,
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  final bool nearBottom = notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 400;
                  if (nearBottom) controller.loadMore();
                  return false;
                },
                child: ListView.separated(
                  padding: padding,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: controller.items.length + 1,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDimens.md),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == controller.items.length) {
                      return _Footer<T>(
                        controller: controller,
                        totalLabel: totalLabel,
                      );
                    }
                    return itemBuilder(context, controller.items[index]);
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _Footer<T> extends StatelessWidget {
  const _Footer({required this.controller, this.totalLabel});

  final BaseListController<T> controller;
  final String? totalLabel;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimens.xl),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final bool atEnd = !controller.pagination.value.hasNextPage &&
          controller.items.isNotEmpty;

      if (atEnd && totalLabel != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.xl),
          child: Center(
            child: Text(
              '${controller.pagination.value.total} $totalLabel',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        );
      }

      return const SizedBox(height: AppDimens.xl);
    });
  }
}

/// The search box every list screen puts under its app bar.
class ListSearchBar extends StatelessWidget implements PreferredSizeWidget {
  const ListSearchBar({
    required this.hintText,
    required this.onChanged,
    super.key,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.screenPadding,
        0,
        AppDimens.screenPadding,
        AppDimens.md,
      ),
      child: TextField(
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded),
        ),
      ),
    );
  }
}
