import 'package:the_general_electric_stores_mobile/features/scanner/constants/scan_symbology.dart';

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
