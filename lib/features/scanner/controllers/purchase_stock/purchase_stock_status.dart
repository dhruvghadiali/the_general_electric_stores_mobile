import 'package:flutter/material.dart';

import 'package:the_general_electric_stores_mobile/features/scanner/controllers/purchase_stock/purchase_stock_controller.dart';

/// What the purchase stock screen says about its own requests.
///
/// Kept apart from the controller because it is copy and iconography, not
/// behaviour: nothing here decides what happens, only how the state that
/// already exists is described. An extension rather than fields on the
/// controller so every value is derived — there is no second copy of the state
/// to fall out of step with the `Rx` values it reads.
///
/// Every getter reads those values directly, so an `Obx` that calls one rebuilds
/// when they change, exactly as if it had read them itself.
extension PurchaseStockStatus on PurchaseStockController {
  // ------------------------------------------------------------- suppliers

  /// The dropdown is live only once there is something in it to choose.
  bool get canChoose => !isLoading.value && suppliers.isNotEmpty;

  /// Retry is offered for a failure, and for an empty list — both are states a
  /// second attempt can change. It is not offered mid-request.
  bool get canRetry =>
      !isLoading.value && (failure.value != null || suppliers.isEmpty);

  /// What the status line says once the request has settled. Null while loading
  /// or when a failure is already being reported, since those speak for
  /// themselves.
  String? get note {
    if (isLoading.value || failure.value != null) return null;

    if (suppliers.isEmpty) {
      return 'No suppliers found. There is nobody to book this stock in '
          'against.';
    }

    if (isTruncated.value) {
      return 'Showing ${suppliers.length} suppliers — there are more than this '
          'picker can load.';
    }

    return '${suppliers.length} '
        'supplier${suppliers.length == 1 ? '' : 's'} loaded.';
  }

  /// The icon beside [note]: a warning for the two states that need attention,
  /// a tick for a list that arrived whole.
  IconData get noteIcon {
    if (suppliers.isEmpty) return Icons.domain_disabled_outlined;
    if (isTruncated.value) return Icons.warning_amber_rounded;
    return Icons.check_circle_outline_rounded;
  }

  // -------------------------------------------------------------- products

  /// The product dropdown is live only once a supplier has been chosen and its
  /// catalogue has arrived — the whole point of the chain is that a product
  /// cannot be picked before the agency it belongs to.
  bool get canChooseProduct =>
      selectedCompanyId != null &&
      !isLoadingProducts.value &&
      products.isNotEmpty;

  bool get canRetryProducts =>
      selectedCompanyId != null &&
      !isLoadingProducts.value &&
      (productFailure.value != null || products.isEmpty);

  /// What the product status line says. "Choose a supplier first" is the state
  /// before anything has been asked for at all, and it is the one worth naming:
  /// a disabled field with nothing underneath it looks broken.
  String? get productNote {
    if (selectedCompanyId == null) {
      return 'Choose a supplier first — products are listed per supplier.';
    }

    if (isLoadingProducts.value || productFailure.value != null) return null;

    if (products.isEmpty) {
      return 'No products found for this supplier.';
    }

    if (isProductTruncated.value) {
      return 'Showing ${products.length} products — there are more than this '
          'picker can load.';
    }

    return '${products.length} '
        'product${products.length == 1 ? '' : 's'} loaded.';
  }

  IconData get productNoteIcon {
    if (selectedCompanyId == null) return Icons.arrow_upward_rounded;
    if (products.isEmpty) return Icons.inventory_2_outlined;
    if (isProductTruncated.value) return Icons.warning_amber_rounded;
    return Icons.check_circle_outline_rounded;
  }
}
