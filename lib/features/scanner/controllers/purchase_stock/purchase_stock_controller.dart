import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/constants/app_constants.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_exception.dart';
import 'package:the_general_electric_stores_mobile/core/services/auth_service.dart';
import 'package:the_general_electric_stores_mobile/features/companies/constants/company_types.dart';
import 'package:the_general_electric_stores_mobile/features/companies/data/models/company_model.dart';
import 'package:the_general_electric_stores_mobile/features/companies/data/repositories/company_repository.dart';
import 'package:the_general_electric_stores_mobile/features/products/data/models/product_model.dart';
import 'package:the_general_electric_stores_mobile/features/products/data/repositories/product_repository.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/purchase_stock/product_selection.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/purchase_stock/stocks_validator.dart';
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

  /// What was typed into the supplier search, kept so reopening the dropdown
  /// does not lose it.
  final RxString supplierQuery = ''.obs;

  // -------------------------------------------------------------- products
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final Rxn<ProductModel> selectedProduct = Rxn<ProductModel>();
  final RxBool isLoadingProducts = false.obs;
  final Rxn<ApiException> productFailure = Rxn<ApiException>();
  final RxBool isProductTruncated = false.obs;
  final RxString productQuery = ''.obs;

  // ---------------------------------------------------------------- stocks
  /// The form the stocks field validates through. Held here rather than in the
  /// view because the view is rebuilt on every `Obx` tick and a key recreated
  /// with it would lose the field's error state.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController stocksInput = TextEditingController();

  /// The typed quantity, or null while it is empty or not yet a valid number.
  int? get stocks => int.tryParse(stocksInput.text.trim());

  /// True when every field on the screen is filled in well enough to act on.
  /// Nothing calls it yet — the screen has no submit — but the rule belongs
  /// with the state it reads, not with the button that will one day use it.
  bool get isComplete =>
      selectedCompanyId != null &&
      selectedProductId != null &&
      validateStocks(stocksInput.text) == null;

  /// The supplier the current product list belongs to.
  ///
  /// Not derived from [selected]: it is what makes reselecting the same
  /// supplier a no-op rather than a second identical request, and it is what an
  /// arriving response is checked against before it is allowed to land.
  String? _productsFor;

  /// Disposed explicitly: a worker outliving its controller would keep firing
  /// against state nothing is listening to.
  Worker? _supplierWatch;

  /// One request per pause in typing, not one per keystroke. A plain [Timer] and
  /// [AppConstants.searchDebounce], matching `BaseListController.search` — the
  /// list screens already behave this way and the delay is theirs to change.
  Timer? _supplierDebounce;
  Timer? _productDebounce;

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
    _supplierDebounce?.cancel();
    _productDebounce?.cancel();
    stocksInput.dispose();
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
        search: supplierQuery.value,
      );

      suppliers.assignAll(page.companies);
      isTruncated.value = !page.isComplete;

      // A reload builds new objects, so the selection is re-pointed at the new
      // instance when it is still in the list. When it is not — which a search
      // does routinely — it is *kept*: narrowing the options is not unchoosing
      // the one already chosen.
      final CompanyModel? refreshed = page.companies.byId(selectedCompanyId);
      if (refreshed != null) selected.value = refreshed;

      // One supplier is not a choice — preselect it and save a tap. Only on an
      // unsearched list: one result for "acm" means the search was narrow, not
      // that the warehouse has one supplier.
      if (supplierQuery.value.trim().isEmpty && page.companies.length == 1) {
        selected.value = page.companies.first;
      }
    } on ApiException catch (error) {
      failure.value = error;
      suppliers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void select(CompanyModel? company) => selected.value = company;

  /// Safe to call on every keystroke: the request waits for a pause.
  void searchSuppliers(String term) {
    supplierQuery.value = term;
    _supplierDebounce?.cancel();
    _supplierDebounce = Timer(
      AppConstants.searchDebounce,
      () => unawaited(load()),
    );
  }

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
    productQuery.value = '';
    _productDebounce?.cancel();

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
        search: productQuery.value,
      );

      // The supplier can be changed again while this request is in flight. A
      // late response for the previous one must not land on top of the new
      // list, so it is dropped rather than shown.
      if (agencyId != _productsFor) return;

      products.assignAll(page.products);
      isProductTruncated.value = !page.isComplete;

      // Kept when a search filters it out, for the same reason as the supplier.
      final ProductModel? refreshed = page.products.byId(selectedProductId);
      if (refreshed != null) selectedProduct.value = refreshed;
    } on ApiException catch (error) {
      if (agencyId != _productsFor) return;
      productFailure.value = error;
      products.clear();
    } finally {
      if (agencyId == _productsFor) isLoadingProducts.value = false;
    }
  }

  void selectProduct(ProductModel? product) => selectedProduct.value = product;

  /// Safe to call on every keystroke: the request waits for a pause.
  void searchProducts(String term) {
    productQuery.value = term;
    _productDebounce?.cancel();
    _productDebounce = Timer(
      AppConstants.searchDebounce,
      () => unawaited(loadProducts()),
    );
  }

  void cancel() => Get.back<Object?>();
}
