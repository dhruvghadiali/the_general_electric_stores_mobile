import 'package:the_general_electric_stores_mobile/features/scanner/constants/scan_symbology.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/models/scanned_code.dart';

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
