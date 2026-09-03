/// The bounds the stocks field accepts.
///
/// Written once here because three places need to agree on them: the input
/// formatter that caps what can be typed, the validator that rejects what was,
/// and the helper text that tells the user before either fires.
class StockLimits {
  const StockLimits._();

  /// Booking in zero units is not a quantity, it is a mistake.
  static const int min = 1;

  static const int max = 100000;

  /// Digits allowed in the box. [max] is six digits, so a seventh could only
  /// ever be out of range — stopping it at the keyboard is kinder than letting
  /// it be typed and then refused.
  static const int maxDigits = 6;
}
