import 'package:the_general_electric_stores_mobile/features/companies/data/models/company_model.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/constants/scan_purpose.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/models/scanned_item.dart';

/// What a completed scanning session hands back: every code read, what they
/// were read for, and who they were read against.
///
/// A list rather than a single code, because one trip to the camera is rarely
/// one item — a delivery is a pallet, and making someone re-choose purpose and
/// company between every carton would be the slowest possible way to work.
class ScanResult {
  const ScanResult({
    required this.items,
    required this.purpose,
    required this.company,
  });

  final List<ScannedItem> items;
  final ScanPurpose purpose;
  final CompanyModel company;

  int get count => items.length;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  /// Every distinct code, in the order first seen. A barcode legitimately
  /// repeats — two identical units carry the same EAN — so the raw count and
  /// the distinct count are both real numbers and mean different things.
  List<String> get distinctCodes =>
      items.map((ScannedItem item) => item.code).toSet().toList();

  @override
  String toString() =>
      'ScanResult(${items.length} items, ${purpose.name}, ${company.name})';
}
