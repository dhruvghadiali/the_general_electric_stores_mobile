import 'package:the_general_electric_stores_mobile/core/constants/api_endpoints.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_client.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_response.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/data/models/dashboard_summary.dart';

/// The dashboard, such as it is.
///
/// Only the employee router mounts one, and it has a single route on it:
/// `GET /employee/dashboard/purchase-credit`. Super admin and warehouse manager
/// mount no dashboard router at all, so asking for theirs would fetch the API's
/// 404 page and surface as a failure on a screen that has simply not been built
/// server-side yet. [summary] answers empty for those roles instead of calling.
class DashboardRepository {
  const DashboardRepository(this._api);

  final ApiClient _api;

  Future<DashboardSummary> summary(UserRole role) async {
    if (!ApiEndpoints.hasDashboard(role)) return DashboardSummary.empty;

    final ApiResponse<DashboardSummary> response =
        await _api.get<DashboardSummary>(
      ApiEndpoints.dashboardPurchaseCredit(role),
      parser: DashboardSummary.fromData,
    );
    return response.data ?? DashboardSummary.empty;
  }
}
