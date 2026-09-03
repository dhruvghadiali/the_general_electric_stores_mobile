import 'package:the_general_electric_stores_mobile/features/scanner/constants/stock_limits.dart';

/// The stocks field's rule, as a pure function.
///
/// Separate from the controller because it needs nothing from it: given the
/// text in the box it returns the message to show, or null when the value is
/// good. That makes it usable straight as a `TextFormField` validator, and
/// testable without building a screen.
///
/// The three cases are deliberately distinct. "Required" and "out of range" are
/// different mistakes and get different wording; a non-numeric string can only
/// arrive if the input formatter is ever removed, and is reported rather than
/// silently treated as empty.
String? validateStocks(String? raw) {
  final String value = raw?.trim() ?? '';

  if (value.isEmpty) return 'Enter how many units are arriving.';

  final int? stocks = int.tryParse(value);
  if (stocks == null) return 'Enter a whole number.';

  if (stocks < StockLimits.min) {
    return 'Must be at least ${StockLimits.min}.';
  }

  if (stocks > StockLimits.max) {
    return 'Must be ${StockLimits.max} or fewer.';
  }

  return null;
}
