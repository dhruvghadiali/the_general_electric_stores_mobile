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
