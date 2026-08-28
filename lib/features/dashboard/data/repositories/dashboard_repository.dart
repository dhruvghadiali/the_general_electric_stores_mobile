import 'package:the_general_electric_stores_mobile/core/constants/api_endpoints.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_client.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_response.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/data/models/dashboard_summary.dart';

/// Each role reads its own dashboard from its own router, so the numbers a
/// warehouse manager sees never come from the same call as a super admin's.
class DashboardRepository {
  const DashboardRepository(this._api);

  final ApiClient _api;

  Future<DashboardSummary> summary(UserRole role) async {
    final ApiResponse<DashboardSummary> response =
        await _api.get<DashboardSummary>(
      ApiEndpoints.dashboard(role),
      parser: DashboardSummary.fromData,
    );
    return response.data ?? DashboardSummary.empty;
  }
}
