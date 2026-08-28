import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/controllers/base_list_controller.dart';
import 'package:the_general_electric_stores_mobile/core/models/list_query.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_response.dart';
import 'package:the_general_electric_stores_mobile/features/products/data/models/product_model.dart';
import 'package:the_general_electric_stores_mobile/features/products/data/repositories/product_repository.dart';

/// The catalogue as an employee sees it: read-only, and only what the
/// `/employee/products` router returns. No create, edit or delete — those are
/// absent from the screen rather than disabled on it, so there is nothing to
/// re-enable by accident.
class EmployeeProductsController extends BaseListController<ProductModel> {
  EmployeeProductsController(this._repository, this.role);

  final ProductRepository _repository;
  final UserRole role;

  @override
  Future<PaginatedResult<ProductModel>> fetchPage(ListQuery query) =>
      _repository.list(role, query);

  void openProduct(ProductModel product) =>
      Get.toNamed<void>(AppRoutes.productDetailPath(product.id));

  void sortByNewest() => sortBy('created_at', order: SortOrder.desc);

  void sortByPriceLowToHigh() => sortBy('price');

  void sortByPriceHighToLow() => sortBy('price', order: SortOrder.desc);
}
