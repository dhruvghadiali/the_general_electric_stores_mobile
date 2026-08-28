import 'package:the_general_electric_stores_mobile/core/utils/formatters.dart';

/// One stock line in the warehouse.
///
/// [quantity] is what is physically on the shelf; [reorderLevel] is the
/// threshold the warehouse works to. The two together decide [status], which
/// is what the list screen actually sorts and colours by.
class StockModel {
  const StockModel({
    required this.id,
    required this.name,
    this.sku,
    this.warehouse,
    this.quantity = 0,
    this.reserved = 0,
    this.reorderLevel = 0,
    this.unit,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? sku;
  final String? warehouse;
  final int quantity;

  /// Committed to orders but not yet dispatched.
  final int reserved;

  final int reorderLevel;
  final String? unit;
  final DateTime? updatedAt;

  int get available => (quantity - reserved).clamp(0, quantity);

  StockStatus get status {
    if (quantity <= 0) return StockStatus.out;
    if (reorderLevel > 0 && quantity <= reorderLevel) return StockStatus.low;
    return StockStatus.healthy;
  }

  String get quantityLabel => '${Formatters.quantity(quantity)} ${unit ?? 'units'}';

  factory StockModel.fromJson(Map<String, dynamic> json) {
    final Object? product = json['product'];
    final String productName = product is Map
        ? '${product['name'] ?? ''}'
        : '${json['name'] ?? json['product_name'] ?? ''}';

    return StockModel(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      name: productName,
      sku: json['sku']?.toString() ??
          (product is Map ? product['sku']?.toString() : null),
      warehouse: _refName(json['warehouse']),
      quantity: _int(json['quantity'] ?? json['stock'] ?? json['on_hand']),
      reserved: _int(json['reserved'] ?? json['reserved_quantity']),
      reorderLevel: _int(json['reorder_level'] ?? json['min_quantity']),
      unit: json['unit']?.toString(),
      updatedAt: Formatters.parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  static int _int(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String? _refName(Object? value) {
    if (value is String) return value;
    if (value is Map) return (value['name'] ?? value['title'])?.toString();
    return null;
  }

  @override
  String toString() => 'StockModel($id, $name, $quantity)';
}

enum StockStatus {
  healthy('In stock'),
  low('Low stock'),
  out('Out of stock');

  const StockStatus(this.label);

  final String label;
}
