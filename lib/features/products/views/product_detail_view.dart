import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/state_views.dart';
import 'package:the_general_electric_stores_mobile/features/products/controllers/product_detail_controller.dart';
import 'package:the_general_electric_stores_mobile/features/products/data/models/product_model.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingView();

        if (controller.failure.value != null) {
          return ErrorView(
            error: controller.failure.value!,
            onRetry: controller.load,
          );
        }

        final ProductModel? product = controller.product;
        if (product == null) {
          return const EmptyView(title: 'This product is no longer available');
        }

        return _Body(product: product);
      }),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      children: <Widget>[
        if (product.thumbnail != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            child: CachedNetworkImage(
              imageUrl: product.thumbnail!,
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const SizedBox(height: 240),
            ),
          ),
        const SizedBox(height: AppDimens.lg),
        Text(product.name, style: theme.textTheme.headlineSmall),
        if (product.brand != null) ...<Widget>[
          const SizedBox(height: AppDimens.xs),
          Text(
            product.brand!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: AppDimens.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Text(product.displayPrice, style: theme.textTheme.headlineMedium),
            if (product.displayMrp != null) ...<Widget>[
              const SizedBox(width: AppDimens.md),
              Text(
                product.displayMrp!,
                style: theme.textTheme.titleMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppDimens.sm),
        Text(
          product.isInStock ? 'In stock' : 'Out of stock',
          style: theme.textTheme.titleSmall?.copyWith(
            color: product.isInStock
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
        ),
        if (product.description != null) ...<Widget>[
          const SizedBox(height: AppDimens.xl),
          Text('Description', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppDimens.sm),
          Text(product.description!, style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: AppDimens.xl),
        const Divider(),
        _Row(label: 'SKU', value: product.sku ?? '—'),
        _Row(label: 'Brand', value: product.brand ?? '—'),
        _Row(label: 'Category', value: product.categoryName ?? '—'),
        _Row(
          label: 'On hand',
          value: '${product.stock} ${product.unit ?? 'units'}',
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
