import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/controllers/base_detail_controller.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/data/models/stock_model.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/data/repositories/stock_repository.dart';

class StockDetailController extends BaseDetailController<StockModel> {
  StockDetailController(this._repository);

  final StockRepository _repository;

  StockModel? get stock => item.value;

  @override
  Future<StockModel> fetch(UserRole role, String id) =>
      _repository.byId(role, id);
}
