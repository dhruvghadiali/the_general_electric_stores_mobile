import 'package:the_general_electric_stores_mobile/features/companies/data/models/company_model.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/constants/scan_purpose.dart';

/// What the purpose chooser and the company picker settled, handed down to the
/// screen that does the scanning.
class ScanContext {
  const ScanContext({required this.purpose, required this.company});

  final ScanPurpose purpose;
  final CompanyModel company;
}
