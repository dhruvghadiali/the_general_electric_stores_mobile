import 'dart:async';

import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_exception.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/data/models/dashboard_summary.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/data/repositories/dashboard_repository.dart';

/// Loading and failure handling shared by all three dashboards.
///
/// Only that is shared. What each role's dashboard *shows* is decided by its
/// own subclass and its own screen, because the figures are different and the
/// actions behind them are different.
abstract class BaseDashboardController extends GetxController {
  BaseDashboardController(this._repository, this.role);

  final DashboardRepository _repository;
  final UserRole role;

  final Rx<DashboardSummary> summary = DashboardSummary.empty.obs;
  final RxBool isLoading = false.obs;
  final Rxn<ApiException> failure = Rxn<ApiException>();

  bool get hasFailed => failure.value != null;

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  Future<void> load() async {
    isLoading.value = true;
    failure.value = null;

    try {
      summary.value = await _repository.summary(role);
    } on ApiException catch (error) {
      failure.value = error;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshSummary() => load();
}
