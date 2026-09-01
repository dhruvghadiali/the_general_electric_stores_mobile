import 'package:flutter/material.dart';

import 'package:the_general_electric_stores_mobile/features/companies/data/models/company_model.dart';

/// Why the camera is being opened.
///
/// The same sticker means different things depending on which direction the
/// stock is moving, so the purpose is chosen *before* the camera opens rather
/// than inferred afterwards — a scanned code with no intent attached is
/// ambiguous, and asking after the fact is a worse moment to interrupt.
enum ScanPurpose {
  purchase(
    label: 'Purchase stock',
    description: 'Items arriving into the warehouse',
    icon: Icons.arrow_downward_rounded,
  ),
  sales(
    label: 'Sales stock',
    description: 'Items going out to a customer',
    icon: Icons.arrow_upward_rounded,
  );

  const ScanPurpose({
    required this.label,
    required this.description,
    required this.icon,
  });

  final String label;
  final String description;
  final IconData icon;
}

/// What kind of code the camera read.
///
/// The split is two-dimensional against one-dimensional, and it is not
/// cosmetic: it changes what the string in hand *is*. A QR is something this
/// business printed, so it carries one of our identifiers or a URL ending in
/// one. A striped barcode down the side of a carton was printed by whoever
/// made the goods, so it carries their product code — `product_code` on the
/// API's product model, which is searchable but is not an id and will never
/// match one.
///
/// Reading them the same way is the mistake this enum exists to prevent.
enum ScanSymbology {
  /// QR, Data Matrix, Aztec, PDF417.
  qr,

  /// EAN-13/8, UPC-A/E, Code 128, Code 39, Code 93, ITF, Codabar.
  barcode,

  /// The camera reported a format this app does not classify. Treat the value
  /// as opaque text rather than assuming either of the above.
  unknown,
}

/// One reading off the camera: the string, and what kind of code carried it.
class ScannedCode {
  const ScannedCode({
    required this.value,
    required this.symbology,
    required this.formatName,
  });

  final String value;
  final ScanSymbology symbology;

  /// The scanner's own name for the format (`ean13`, `qrCode`). Kept for logs
  /// and for the day one specific format needs handling of its own.
  final String formatName;

  @override
  String toString() => 'ScannedCode($value, $formatName)';
}

/// One code, kept: what it said, what kind of code it was, and when it was
/// read.
///
/// The timestamp is not bookkeeping. Someone working a pallet scans a dozen
/// labels in a row, and when the list looks wrong afterwards the only question
/// worth answering is which reading came in when — a mis-scan two items ago
/// looks identical to a correct one without it.
class ScannedItem {
  const ScannedItem({
    required this.code,
    required this.symbology,
    required this.scannedAt,
  });

  /// Promotes a reading off the camera into a kept item.
  factory ScannedItem.from(ScannedCode scanned, {DateTime? at}) => ScannedItem(
        code: scanned.value,
        symbology: scanned.symbology,
        scannedAt: at ?? DateTime.now(),
      );

  final String code;
  final ScanSymbology symbology;
  final DateTime scannedAt;

  /// True when the code came off a manufacturer's barcode, so it names a
  /// product code rather than one of this system's ids.
  bool get isProductBarcode => symbology == ScanSymbology.barcode;

  String get symbologyLabel => switch (symbology) {
        ScanSymbology.qr => 'QR',
        ScanSymbology.barcode => 'Barcode',
        ScanSymbology.unknown => 'Unrecognised',
      };

  @override
  String toString() => 'ScannedItem($code, ${symbology.name})';
}

/// What the purpose chooser and the company picker settled, handed down to the
/// screen that does the scanning.
class ScanContext {
  const ScanContext({required this.purpose, required this.company});

  final ScanPurpose purpose;
  final CompanyModel company;
}

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
