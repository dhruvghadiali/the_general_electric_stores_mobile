/// The `company_type` values the API filters the company list on.
///
/// Only what this app actually asks for is listed. The value is the string the
/// server matches, so it is written once here rather than at each call site —
/// a typo in a filter is not an error, it is an empty list.
class CompanyTypes {
  const CompanyTypes._();

  /// Companies the business buys from.
  static const String supplier = 'supplier';
}
