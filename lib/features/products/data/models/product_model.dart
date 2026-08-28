import 'package:the_general_electric_stores_mobile/core/utils/formatters.dart';

/// A product as the API returns it.
///
/// Every field is read defensively: a list screen must not blow up because one
/// row is missing a price or carries a populated object where an id was
/// expected.
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    this.sku,
    this.description,
    this.price = 0,
    this.mrp,
    this.stock = 0,
    this.unit,
    this.brand,
    this.categoryId,
    this.categoryName,
    this.images = const <String>[],
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? sku;
  final String? description;
  final num price;
  final num? mrp;
  final int stock;
  final String? unit;
  final String? brand;
  final String? categoryId;
  final String? categoryName;
  final List<String> images;
  final bool isActive;
  final DateTime? createdAt;

  bool get isInStock => stock > 0;

  String? get thumbnail => images.isEmpty ? null : images.first;

  String get displayPrice => Formatters.currency(price);

  String? get displayMrp =>
      (mrp != null && mrp! > price) ? Formatters.currency(mrp) : null;

  int? get discountPercent {
    if (mrp == null || mrp! <= price || mrp == 0) return null;
    return (((mrp! - price) / mrp!) * 100).round();
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      name: '${json['name'] ?? json['title'] ?? ''}',
      sku: json['sku']?.toString(),
      description: json['description']?.toString(),
      price: _num(json['price'] ?? json['selling_price']),
      mrp: json['mrp'] == null ? null : _num(json['mrp']),
      stock: _num(json['stock'] ?? json['quantity']).toInt(),
      unit: json['unit']?.toString(),
      brand: _refName(json['brand']),
      categoryId: _refId(json['category']),
      categoryName: _refName(json['category']),
      images: _images(json['images'] ?? json['image']),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: Formatters.parseDate(json['created_at'] ?? json['createdAt']),
    );
  }

  static num _num(Object? value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

  /// A reference field arrives either as a raw ObjectId string or, when the
  /// controller populated it, as the whole document.
  static String? _refId(Object? value) {
    if (value is String) return value;
    if (value is Map) return value['_id']?.toString();
    return null;
  }

  static String? _refName(Object? value) {
    if (value is Map) return (value['name'] ?? value['title'])?.toString();
    return null;
  }

  static List<String> _images(Object? value) {
    if (value is String && value.isNotEmpty) return <String>[value];
    if (value is List) {
      return value
          .map((Object? item) {
            if (item is String) return item;
            if (item is Map) return item['url']?.toString() ?? '';
            return '';
          })
          .where((String url) => url.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }

  @override
  String toString() => 'ProductModel($id, $name)';
}
