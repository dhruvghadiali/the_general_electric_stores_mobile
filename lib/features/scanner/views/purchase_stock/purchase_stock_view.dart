import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/searchable_dropdown_field/searchable_dropdown_field.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/request_status_line/request_status_line.dart';
import 'package:the_general_electric_stores_mobile/features/companies/data/models/company_model.dart';
import 'package:the_general_electric_stores_mobile/features/products/data/models/product_model.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/purchase_stock/purchase_stock_controller.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/purchase_stock/purchase_stock_status.dart';

/// Where "Purchase stock" lands: items arriving into the warehouse.
///
/// The supplier is asked for first because it is the one fact that scopes
/// everything after it — the list comes from the API already filtered to
/// `company_type=supplier`, so nothing a customer-only company owns can be
/// picked here by mistake.
///
/// The product below it is a chain, not a second independent field: choosing a
/// supplier fetches that supplier's catalogue (`agency=<company id>`), and the
/// product dropdown stays disabled until it lands.
///
/// Both dropdowns are on screen from the first frame, empty and disabled while
/// their list loads, with each request's own state reported underneath its own
/// field. Nothing moves when the rows arrive, and a failure reads as "this field
/// has nothing in it yet" rather than as a broken screen.
class PurchaseStockView extends GetView<PurchaseStockController> {
  const PurchaseStockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase stock'),
        leading: IconButton(
          onPressed: controller.cancel,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          children: <Widget>[
            Obx(
              () => SearchableDropdownField<CompanyModel>(
                label: 'Supplier',
                hint: controller.isLoading.value
                    ? 'Loading suppliers…'
                    : 'Choose a supplier',
                searchHint: 'Search suppliers',
                prefixIcon: Icons.domain_outlined,
                items: controller.suppliers,
                isLoading: controller.isLoading,
                error: controller.failure,
                itemLabel: (CompanyModel company) => company.name,
                itemSubtitle: (CompanyModel company) =>
                    company.subtitle.isEmpty ? null : company.subtitle,
                value: controller.selected.value,
                query: controller.supplierQuery.value,
                onSearch: controller.searchSuppliers,
                onChanged: controller.select,
                onRetry: controller.load,
                emptyMessage: 'No suppliers matched that search.',
                enabled: controller.canChoose,
              ),
            ),
            Obx(
              () => RequestStatusLine(
                isLoading: controller.isLoading.value,
                loadingMessage: 'Loading suppliers…',
                error: controller.failure.value,
                onRetry: controller.canRetry ? controller.load : null,
                note: controller.note,
                noteIcon: controller.noteIcon,
                noteTone: controller.isTruncated.value
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            Obx(
              () => SearchableDropdownField<ProductModel>(
                label: 'Product',
                hint: controller.isLoadingProducts.value
                    ? 'Loading products…'
                    : 'Choose a product',
                searchHint: 'Search products',
                prefixIcon: Icons.inventory_2_outlined,
                items: controller.products,
                isLoading: controller.isLoadingProducts,
                error: controller.productFailure,
                // Code first, in brackets, then the name: the code is what a
                // carton is labelled with, so it is what someone reads off the
                // box and looks for in the list.
                itemLabel: (ProductModel product) => product.sku == null
                    ? product.name
                    : '(${product.sku}) ${product.name}',
                value: controller.selectedProduct.value,
                query: controller.productQuery.value,
                onSearch: controller.searchProducts,
                onChanged: controller.selectProduct,
                onRetry: controller.loadProducts,
                emptyMessage: 'No products matched that search.',
                enabled: controller.canChooseProduct,
              ),
            ),
            Obx(
              () => RequestStatusLine(
                isLoading: controller.isLoadingProducts.value,
                loadingMessage: 'Loading products…',
                error: controller.productFailure.value,
                onRetry:
                    controller.canRetryProducts ? controller.loadProducts : null,
                note: controller.productNote,
                noteIcon: controller.productNoteIcon,
                noteTone: controller.isProductTruncated.value
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
