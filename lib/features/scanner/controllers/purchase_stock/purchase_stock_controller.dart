import 'dart:async';

import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_exception.dart';
import 'package:the_general_electric_stores_mobile/core/services/auth_service.dart';
import 'package:the_general_electric_stores_mobile/features/companies/constants/company_types.dart';
import 'package:the_general_electric_stores_mobile/features/companies/data/models/company_model.dart';
import 'package:the_general_electric_stores_mobile/features/companies/data/repositories/company_repository.dart';
import 'package:the_general_electric_stores_mobile/features/products/data/models/product_model.dart';
import 'package:the_general_electric_stores_mobile/features/products/data/repositories/product_repository.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/purchase_stock/product_selection.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/purchase_stock/supplier_selection.dart';

/// Purchase stock: which supplier are these goods arriving from, and which of
/// that supplier's products are they?
///
/// The two questions are a chain, not two independent fields: a product only
/// makes sense once its agency is known, so the product list is fetched with
/// `agency=<company id>` the moment a supplier is chosen and the product
/// dropdown stays disabled until it arrives.
///
/// This file owns the requests and the state they produce. What the screen
/// *says* about that state — the wording of each status line, which icon goes
/// beside it, whether a dropdown is live — is in `purchase_stock_status.dart`,
/// so the loading rules and the copy can be read, and changed, independently.
///
/// Both lists are filtered on the server rather than fetched whole and sieved
/// here: a client-side filter over a paged endpoint is right only until the
/// rows stop fitting on the pages it happened to read.
class PurchaseStockController extends GetxController {
  PurchaseStockController(this._companies, this._products);

  final CompanyRepository _companies;
  final ProductRepository _products;

  // ------------------------------------------------------------- suppliers
  final RxList<CompanyModel> suppliers = <CompanyModel>[].obs;
  final Rxn<CompanyModel> selected = Rxn<CompanyModel>();
  final RxBool isLoading = false.obs;
  final Rxn<ApiException> failure = Rxn<ApiException>();

  /// True when the API holds more suppliers than the walk was willing to fetch,
  /// so the dropdown is showing a prefix rather than all of them.
  final RxBool isTruncated = false.obs;

  // -------------------------------------------------------------- products
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final Rxn<ProductModel> selectedProduct = Rxn<ProductModel>();
  final RxBool isLoadingProducts = false.obs;
  final Rxn<ApiException> productFailure = Rxn<ApiException>();
  final RxBool isProductTruncated = false.obs;

  /// The supplier the current product list belongs to.
  ///
  /// Not derived from [selected]: it is what makes reselecting the same
  /// supplier a no-op rather than a second identical request, and it is what an
  /// arriving response is checked against before it is allowed to land.
  String? _productsFor;

  /// Disposed explicitly: a worker outliving its controller would keep firing
  /// against state nothing is listening to.
  Worker? _supplierWatch;

  UserRole? get role => AuthService.to.role.value;

  /// What the supplier selection is worth to everything downstream: the
  /// company's id.
  ///
  /// The state is the whole [CompanyModel] rather than this string, so a screen
  /// that later needs the supplier's address, GST number or contacts reads them
  /// off [selected] instead of fetching the company again. The label a person
  /// reads is `selected.value.name`; the value a request carries is this.
  String? get selectedCompanyId => selected.value?.id;

  /// The same again for the product: the id is the value, the model is the
  /// state, so price and stock on hand are there when a later step wants them.
  String? get selectedProductId => selectedProduct.value?.id;

  @override
  void onInit() {
    super.onInit();

    // A worker rather than a call inside `select`, because the supplier can also
    // be set by [load] preselecting a sole supplier — and that case needs the
    // products just as much as a tap does.
    _supplierWatch = ever<CompanyModel?>(selected, _onSupplierChanged);

    unawaited(load());
  }

  @override
  void onClose() {
    _supplierWatch?.dispose();
    super.onClose();
  }

  // ------------------------------------------------------------- suppliers

  Future<void> load() async {
    final UserRole? current = role;
    if (current == null) return;

    isLoading.value = true;
    failure.value = null;

    try {
      final CompanyPage page = await _companies.activeCompanies(
        current,
        companyType: CompanyTypes.supplier,
      );

      // A reload builds new objects, and the dropdown matches its value against
      // its items by identity — so carry the selection across by id, or drop it
      // if that supplier is no longer in the list.
      final String? chosenId = selectedCompanyId;

      suppliers.assignAll(page.companies);
      isTruncated.value = !page.isComplete;

      selected.value = page.companies.byId(chosenId);

      // One supplier is not a choice — preselect it and save a tap.
      if (page.companies.length == 1) selected.value = page.companies.first;
    } on ApiException catch (error) {
      failure.value = error;
      suppliers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void select(CompanyModel? company) => selected.value = company;

  // -------------------------------------------------------------- products

  /// Clears the product half and refetches it for the supplier now chosen.
  ///
  /// Reselecting the same supplier is ignored: the list on screen already
  /// belongs to it, and refetching would throw away a product the user had
  /// already picked.
  void _onSupplierChanged(CompanyModel? company) {
    if (company?.id == _productsFor) return;

    _productsFor = company?.id;

    products.clear();
    selectedProduct.value = null;
    productFailure.value = null;
    isProductTruncated.value = false;

    // A request already in flight for the previous supplier will not clear this
    // when it returns — it checks that it is still wanted and drops out — so the
    // flag is reset here, and the next request sets it again immediately.
    isLoadingProducts.value = false;

    if (company != null) unawaited(loadProducts());
  }

  Future<void> loadProducts() async {
    final UserRole? current = role;
    final String? agencyId = selectedCompanyId;
    if (current == null || agencyId == null) return;

    isLoadingProducts.value = true;
    productFailure.value = null;

    try {
      final ProductPage page = await _products.activeProducts(
        current,
        agencyId: agencyId,
      );

      // The supplier can be changed again while this request is in flight. A
      // late response for the previous one must not land on top of the new
      // list, so it is dropped rather than shown.
      if (agencyId != _productsFor) return;

      final String? chosenId = selectedProductId;

      products.assignAll(page.products);
      isProductTruncated.value = !page.isComplete;

      selectedProduct.value = page.products.byId(chosenId);
    } on ApiException catch (error) {
      if (agencyId != _productsFor) return;
      productFailure.value = error;
      products.clear();
    } finally {
      if (agencyId == _productsFor) isLoadingProducts.value = false;
    }
  }

  void selectProduct(ProductModel? product) => selectedProduct.value = product;

  void cancel() => Get.back<Object?>();
}
