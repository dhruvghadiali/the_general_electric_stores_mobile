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

  /// The query behind the product picker, written exactly as the API wants it:
  ///
  /// ```
  /// ?is_active=true&agency=<company id>&sort=name:asc
  /// ```
  ///
  /// A plain map rather than a [ListQuery] because that always emits `page` and
  /// `limit`, and this call is defined by the keys above — the server's own
  /// default page size decides the rest.
  ///
  /// `agency` is the supplier: the API names a product's company that way, and
  /// scoping on the server rather than filtering here is what keeps the list
  /// correct once the catalogue outgrows one page.
  static Map<String, dynamic> pickerQuery({String? agencyId}) {
    return <String, dynamic>{
      'is_active': true,
      if (agencyId != null) 'agency': agencyId,
      'sort': 'name:asc',
    };
  }

  /// Every active product of one agency, gathered a page at a time.
  ///
  /// Rows are parsed whole rather than trimmed to what a dropdown shows: the
  /// same call feeds a picker that needs a name and a code today, and a screen
  /// that will want the price or stock on hand tomorrow.
  ///
  /// [maxPages] is a stop, not a page size: it bounds a `total_pages` the server
  /// got wrong. Reaching it is reported rather than hidden — see
  /// [ProductPage.isComplete].
  Future<ProductPage> activeProducts(
    UserRole role, {
    String? agencyId,
    int maxPages = 25,
  }) async {
    final List<ProductModel> all = <ProductModel>[];
    Map<String, dynamic> query = pickerQuery(agencyId: agencyId);

    for (int fetched = 0; fetched < maxPages; fetched++) {
      final PaginatedResult<ProductModel> page = await _products(role, query);
      all.addAll(page.items);

      // An empty page ends the walk whatever the pagination block claims.
      if (page.items.isEmpty || !page.pagination.hasNextPage) {
        return ProductPage(products: all, isComplete: true);
      }

      query = <String, dynamic>{...query, 'page': page.pagination.nextPage};
    }

    return ProductPage(products: all, isComplete: false);
  }

  /// One page of `GET /{role}/products`.
  ///
  /// `products` is the key the API's list controller uses inside `data`
  /// (`{ products, summary, sort, pagination }`).
  Future<PaginatedResult<ProductModel>> list(
    UserRole role,
    ListQuery query,
  ) =>
      _products(role, query.toQueryParameters());

  /// The one place a product list is fetched and parsed.
  Future<PaginatedResult<ProductModel>> _products(
    UserRole role,
    Map<String, dynamic> query,
  ) async {
    final ApiResponse<PaginatedResult<ProductModel>> response =
        await _api.get<PaginatedResult<ProductModel>>(
      ApiEndpoints.products(role),
      query: query,
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

/// The result of gathering every page of the product picker query.
///
/// [isComplete] is false only when the walk hit its page cap, which means the
/// dropdown is holding a prefix of the catalogue rather than all of it.
class ProductPage {
  const ProductPage({required this.products, required this.isComplete});

  final List<ProductModel> products;
  final bool isComplete;
}
