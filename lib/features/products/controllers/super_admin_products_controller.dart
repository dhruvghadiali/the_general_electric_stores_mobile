import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/controllers/base_list_controller.dart';
import 'package:the_general_electric_stores_mobile/core/models/list_query.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_response.dart';
import 'package:the_general_electric_stores_mobile/core/utils/app_snackbar.dart';
import 'package:the_general_electric_stores_mobile/features/products/data/models/product_model.dart';
import 'package:the_general_electric_stores_mobile/features/products/data/repositories/product_repository.dart';

/// The catalogue as a super admin sees it: the full list, plus the actions
/// only they have. Paging, search and retry come from [BaseListController];
/// this class says where a page comes from and what a super admin may do
/// with it.
class SuperAdminProductsController extends BaseListController<ProductModel> {
  SuperAdminProductsController(this._repository, this.role);

  final ProductRepository _repository;
  final UserRole role;

  /// Actions the employee screen deliberately does not offer.
  bool get canCreate => true;

  @override
  Future<PaginatedResult<ProductModel>> fetchPage(ListQuery query) =>
      _repository.list(role, query);

  void openProduct(ProductModel product) =>
      Get.toNamed<void>(AppRoutes.productDetailPath(product.id));

  void createProduct() {
    // TODO(products): POST /super-admin/products once the form exists.
    AppSnackbar.info('Adding products is not built yet.');
  }

  void sortByNewest() => sortBy('created_at', order: SortOrder.desc);

  void sortByPriceLowToHigh() => sortBy('price');

  void sortByPriceHighToLow() => sortBy('price', order: SortOrder.desc);
}
