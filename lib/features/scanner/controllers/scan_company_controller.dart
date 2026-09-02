import 'dart:async';

import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_exception.dart';
import 'package:the_general_electric_stores_mobile/core/services/auth_service.dart';
import 'package:the_general_electric_stores_mobile/features/companies/data/models/company_model.dart';
import 'package:the_general_electric_stores_mobile/features/companies/data/repositories/company_repository.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/constants/scan_purpose.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/models/scan_context.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/models/scan_result.dart';

/// Picks the company a scan is attributed to, then opens the camera.
///
/// The whole list is gathered before the dropdown opens — the repository walks
/// `page=1,2,3…` at the API's page size of 20 — because a dropdown that fetches
/// while the user is scrolling it is a bad control. That walk has a ceiling;
/// [isTruncated] is how the screen says so rather than quietly showing a
/// prefix of the companies.
class ScanCompanyController extends GetxController {
  ScanCompanyController(this._repository);

  final CompanyRepository _repository;

  final RxList<CompanyModel> companies = <CompanyModel>[].obs;
  final Rxn<CompanyModel> selected = Rxn<CompanyModel>();
  final RxBool isLoading = false.obs;
  final Rxn<ApiException> failure = Rxn<ApiException>();

  /// True when the API holds more companies than the walk was willing to fetch,
  /// so the list on screen is a prefix rather than all of them.
  final RxBool isTruncated = false.obs;

  /// Set by the purpose chooser, and passed on to the camera.
  ScanPurpose get purpose {
    final Object? argument = Get.arguments;
    return argument is ScanPurpose ? argument : ScanPurpose.purchase;
  }

  UserRole? get role => AuthService.to.role.value;

  bool get canContinue => selected.value != null && !isLoading.value;

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
      // Active companies only, ordered by name — the repository owns that
      // query, so the picker and any other company dropdown ask for the same
      // rows in the same order.
      final CompanyPage page = await _repository.activeCompanies(current);

      companies.assignAll(page.companies);
      isTruncated.value = !page.isComplete;

      // One company is not a choice — preselect it and save a tap.
      if (page.companies.length == 1) selected.value = page.companies.first;
    } on ApiException catch (error) {
      failure.value = error;
      companies.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void select(CompanyModel? company) => selected.value = company;

  /// Opens the scanning session, then hands its result back up to the chooser.
  ///
  /// The camera is one hop further on. This screen's job ends at "what is this
  /// against", and the session screen owns the codes — which is what lets one
  /// choice of purpose and company cover a whole pallet.
  Future<void> continueToScan() async {
    final CompanyModel? company = selected.value;
    if (company == null) return;

    // `Object?`, not `ScanResult`. GetX's onGenerateRoute always builds a
    // `GetPageRoute<dynamic>`, and a non-top-type generic makes the push throw
    // on the cast, so the narrowing happens here instead.
    final Object? session = await Get.toNamed<Object?>(
      AppRoutes.scanItems,
      arguments: ScanContext(purpose: purpose, company: company),
    );

    // Null means the session was abandoned, which is not the same as a session
    // that read nothing — either way there is nothing to pass on.
    if (session is! ScanResult || session.isEmpty) return;

    Get.back<Object?>(result: session);
  }

  void cancel() => Get.back<Object?>();
}
