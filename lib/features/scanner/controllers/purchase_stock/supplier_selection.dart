import 'package:the_general_electric_stores_mobile/features/companies/data/models/company_model.dart';

/// Finding a company in a freshly fetched list by the id of the one that was
/// selected before it.
extension SupplierSelection on List<CompanyModel> {
  /// The company with this id, or null — including when [id] itself is null, so
  /// "nothing was selected" and "the selection is gone" collapse into the one
  /// answer the caller wants either way.
  CompanyModel? byId(String? id) {
    if (id == null) return null;

    for (final CompanyModel company in this) {
      if (company.id == id) return company;
    }
    return null;
  }
}
