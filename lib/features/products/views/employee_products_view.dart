import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/widgets/paged_list_view.dart';
import 'package:the_general_electric_stores_mobile/features/products/controllers/employee_products_controller.dart';
import 'package:the_general_electric_stores_mobile/features/products/data/models/product_model.dart';
import 'package:the_general_electric_stores_mobile/features/products/widgets/product_card.dart';
import 'package:the_general_electric_stores_mobile/features/products/widgets/product_sort_sheet.dart';

/// The catalogue for an employee — browse and search only. There is no create
/// action here at all, rather than one that is greyed out.
class EmployeeProductsView extends GetView<EmployeeProductsController> {
  const EmployeeProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: <Widget>[
          IconButton(
            onPressed: () => showProductSortSheet(
              context,
              onNewest: controller.sortByNewest,
              onPriceAscending: controller.sortByPriceLowToHigh,
              onPriceDescending: controller.sortByPriceHighToLow,
            ),
            icon: const Icon(Icons.swap_vert_rounded),
            tooltip: 'Sort',
          ),
        ],
        bottom: ListSearchBar(
          hintText: 'Search products',
          onChanged: controller.search,
        ),
      ),
      body: PagedListView<ProductModel>(
        controller: controller,
        loadingMessage: 'Loading products…',
        emptyTitle: 'Nothing here yet',
        emptyMessage: 'No products matched this search.',
        emptyIcon: Icons.inventory_2_outlined,
        totalLabel: 'products',
        itemBuilder: (BuildContext context, ProductModel product) =>
            ProductCard(
          product: product,
          onTap: () => controller.openProduct(product),
        ),
      ),
    );
  }
}
