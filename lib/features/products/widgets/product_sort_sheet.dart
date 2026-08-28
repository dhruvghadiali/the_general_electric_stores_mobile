import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';

/// The sort options a product list offers. Shared by both role screens because
/// sorting a price column is the same act whoever is doing it.
void showProductSortSheet(
  BuildContext context, {
  required VoidCallback onNewest,
  required VoidCallback onPriceAscending,
  required VoidCallback onPriceDescending,
}) {
  Get.bottomSheet<void>(
    SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: AppDimens.sm),
          ListTile(
            leading: const Icon(Icons.new_releases_outlined),
            title: const Text('Newest first'),
            onTap: () {
              Get.back<void>();
              onNewest();
            },
          ),
          ListTile(
            leading: const Icon(Icons.arrow_upward_rounded),
            title: const Text('Price: low to high'),
            onTap: () {
              Get.back<void>();
              onPriceAscending();
            },
          ),
          ListTile(
            leading: const Icon(Icons.arrow_downward_rounded),
            title: const Text('Price: high to low'),
            onTap: () {
              Get.back<void>();
              onPriceDescending();
            },
          ),
          const SizedBox(height: AppDimens.sm),
        ],
      ),
    ),
    backgroundColor: Theme.of(context).colorScheme.surface,
  );
}
