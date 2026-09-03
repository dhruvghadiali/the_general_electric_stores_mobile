import 'dart:async';

import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_exception.dart';
import 'package:the_general_electric_stores_mobile/core/services/auth_service.dart';
import 'package:the_general_electric_stores_mobile/features/companies/constants/company_types.dart';
import 'package:the_general_electric_stores_mobile/features/companies/data/models/company_option.dart';
import 'package:the_general_electric_stores_mobile/features/companies/data/repositories/company_repository.dart';

/// Purchase stock: which supplier are these goods arriving from?
///
/// The list is filtered on the server (`company_type=supplier`) rather than
/// fetched whole and sieved here — a client-side filter over a paged endpoint
/// is right only until the suppliers stop fitting on the pages it happened to
/// read.
class PurchaseStockController extends GetxController {
  PurchaseStockController(this._repository);

  final CompanyRepository _repository;

  final RxList<CompanyOption> suppliers = <CompanyOption>[].obs;
  final Rxn<CompanyOption> selected = Rxn<CompanyOption>();
  final RxBool isLoading = false.obs;
  final Rxn<ApiException> failure = Rxn<ApiException>();

  /// True when the API holds more suppliers than the walk was willing to fetch,
  /// so the dropdown is showing a prefix rather than all of them.
  final RxBool isTruncated = false.obs;

  UserRole? get role => AuthService.to.role.value;

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  Future<void> load() async {
    final UserRole? current = role;
    if (current == null) return;

    isLoading.value = true;
    failure.value = null;

    try {
      final CompanyOptionPage page = await _repository.companyOptions(
        current,
        companyType: CompanyTypes.supplier,
      );

      suppliers.assignAll(page.options);
      isTruncated.value = !page.isComplete;

      // Keep a selection the user already made across a reload; the rows are
      // rebuilt objects, so this relies on `CompanyOption`'s id equality.
      final CompanyOption? chosen = selected.value;
      if (chosen != null && !page.options.contains(chosen)) {
        selected.value = null;
      }

      // One supplier is not a choice — preselect it and save a tap.
      if (page.options.length == 1) selected.value = page.options.first;
    } on ApiException catch (error) {
      failure.value = error;
      suppliers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void select(CompanyOption? company) => selected.value = company;

  void cancel() => Get.back<Object?>();
}
