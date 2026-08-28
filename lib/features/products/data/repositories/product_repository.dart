import 'package:the_general_electric_stores_mobile/core/constants/api_endpoints.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/models/list_query.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_client.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_response.dart';
import 'package:the_general_electric_stores_mobile/features/products/data/models/product_model.dart';

/// Products, scoped to the signed-in role.
///
/// One repository serves both super admin and employee — the *data* shape is
/// the same, the *path* is not. What differs per role is what each controller
/// does with it and what each screen offers, which is why the controllers are
/// separate and this is not.
class ProductRepository {
  const ProductRepository(this._api);

  final ApiClient _api;

  /// One page of `GET /{role}/products`.
  ///
  /// `products` is the key the API's list controller uses inside `data`
  /// (`{ products, summary, sort, pagination }`).
  Future<PaginatedResult<ProductModel>> list(
    UserRole role,
    ListQuery query,
  ) async {
    final ApiResponse<PaginatedResult<ProductModel>> response =
        await _api.get<PaginatedResult<ProductModel>>(
      ApiEndpoints.products(role),
      query: query.toQueryParameters(),
      parser: (Object? data) => PaginatedResult<ProductModel>.fromData(
        data,
        itemsKey: 'products',
        parser: ProductModel.fromJson,
      ),
    );
    return response.data!;
  }

  Future<ProductModel> byId(UserRole role, String id) async {
    final ApiResponse<ProductModel> response = await _api.get<ProductModel>(
      ApiEndpoints.product(role, id),
      parser: (Object? data) => ProductModel.fromJson(firstObject(data)),
    );
    return response.data!;
  }
}
