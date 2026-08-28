import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/network/api_client.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/controllers/contact_detail_controller.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/data/repositories/contact_repository.dart';
import 'package:the_general_electric_stores_mobile/features/products/controllers/product_detail_controller.dart';
import 'package:the_general_electric_stores_mobile/features/products/data/repositories/product_repository.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/controllers/stock_detail_controller.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/data/repositories/stock_repository.dart';

/// Detail routes sit outside the shell — they are pushed over it — so they
/// register their own dependencies. Each is guarded by the destination it
/// belongs to, so a role without that tab cannot reach the route at all.
class ProductDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRepository>(
      () => ProductRepository(ApiClient.to),
      fenix: true,
    );
    Get.lazyPut<ProductDetailController>(
      () => ProductDetailController(Get.find()),
    );
  }
}

class ContactDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContactRepository>(
      () => ContactRepository(ApiClient.to),
      fenix: true,
    );
    Get.lazyPut<ContactDetailController>(
      () => ContactDetailController(Get.find()),
    );
  }
}

class StockDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StockRepository>(
      () => StockRepository(ApiClient.to),
      fenix: true,
    );
    Get.lazyPut<StockDetailController>(
      () => StockDetailController(Get.find()),
    );
  }
}
