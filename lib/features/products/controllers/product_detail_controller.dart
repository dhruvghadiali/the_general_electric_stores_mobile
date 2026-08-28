import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/controllers/base_detail_controller.dart';
import 'package:the_general_electric_stores_mobile/features/products/data/models/product_model.dart';
import 'package:the_general_electric_stores_mobile/features/products/data/repositories/product_repository.dart';

class ProductDetailController extends BaseDetailController<ProductModel> {
  ProductDetailController(this._repository);

  final ProductRepository _repository;

  ProductModel? get product => item.value;

  @override
  Future<ProductModel> fetch(UserRole role, String id) =>
      _repository.byId(role, id);
}
