import 'package:the_general_electric_stores_mobile/features/products/data/models/product_model.dart';

/// Finding a product in a freshly fetched list by the id of the one that was
/// selected before it.
extension ProductSelection on List<ProductModel> {
  /// The product with this id, or null — including when [id] itself is null, so
  /// "nothing was selected" and "the selection is gone" collapse into the one
  /// answer the caller wants either way.
  ProductModel? byId(String? id) {
    if (id == null) return null;

    for (final ProductModel product in this) {
      if (product.id == id) return product;
    }
    return null;
  }
}
