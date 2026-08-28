import 'package:the_general_electric_stores_mobile/core/constants/api_endpoints.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/models/list_query.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_client.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_response.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/data/models/stock_model.dart';

/// Stock lines, scoped to the warehouse manager's router.
class StockRepository {
  const StockRepository(this._api);

  final ApiClient _api;

  Future<PaginatedResult<StockModel>> list(
    UserRole role,
    ListQuery query,
  ) async {
    final ApiResponse<PaginatedResult<StockModel>> response =
        await _api.get<PaginatedResult<StockModel>>(
      ApiEndpoints.stocks(role),
      query: query.toQueryParameters(),
      parser: (Object? data) => PaginatedResult<StockModel>.fromData(
        data,
        itemsKey: 'stocks',
        parser: StockModel.fromJson,
      ),
    );
    return response.data!;
  }

  Future<StockModel> byId(UserRole role, String id) async {
    final ApiResponse<StockModel> response = await _api.get<StockModel>(
      ApiEndpoints.stock(role, id),
      parser: (Object? data) => StockModel.fromJson(firstObject(data)),
    );
    return response.data!;
  }
}
