import 'package:the_general_electric_stores_mobile/core/constants/api_endpoints.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/models/list_query.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_client.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_response.dart';
import 'package:the_general_electric_stores_mobile/features/companies/data/models/company_model.dart';

/// Companies, scoped to the signed-in role's router.
///
/// ```
/// GET /warehouse-manager/companies
///     ?is_active=true&company_type=supplier&sort=company_name:asc
/// ```
///
/// All three roles may list companies; only an employee may read one or write
/// any, so this repository is a list and nothing else.
class CompanyRepository {
  const CompanyRepository(this._api);

  final ApiClient _api;

  /// The query behind every company picker, written exactly as the API wants
  /// it:
  ///
  /// ```
  /// ?is_active=true&company_type=supplier&sort=company_name:asc
  /// ```
  ///
  /// A plain map rather than a [ListQuery] because that always emits `page` and
  /// `limit`, and this call is defined by the keys above — the server's own
  /// default page size decides the rest.
  ///
  /// `sort` rather than `sort_by`/`sort_order` — the API accepts both but makes
  /// them mutually exclusive (`.oxor`), and the single-token form is the one
  /// that cannot fall out of step with itself. `company_name` is also the only
  /// company column the API gives English collation to, so `acme` sorts before
  /// `Bharat` instead of after it.
  ///
  /// [companyType] is omitted entirely when null, so a picker that wants every
  /// company and one that wants suppliers share this single query.
  static Map<String, dynamic> pickerQuery({String? companyType}) {
    return <String, dynamic>{
      'is_active': true,
      if (companyType != null) 'company_type': companyType,
      'sort': 'company_name:asc',
    };
  }

  /// Every active company, gathered a page at a time, as full [CompanyModel]s.
  ///
  /// The rows are parsed whole rather than trimmed to what a dropdown shows:
  /// the same call feeds pickers that only need a name today and screens that
  /// will want the address, GST number or contacts tomorrow, and none of them
  /// should need a second endpoint or a second model to get there.
  ///
  /// The first request is [pickerQuery] verbatim. Further pages are asked for
  /// only when `pagination` reports them, so the common case is one request and
  /// a list that outgrows the server's page size does not silently lose its
  /// tail.
  ///
  /// [maxPages] is a stop, not a page size: it bounds a `total_pages` the
  /// server got wrong. Reaching it is reported rather than hidden — see
  /// [CompanyPage.isComplete].
  Future<CompanyPage> activeCompanies(
    UserRole role, {
    String? companyType,
    int maxPages = 25,
  }) async {
    final List<CompanyModel> all = <CompanyModel>[];
    Map<String, dynamic> query = pickerQuery(companyType: companyType);

    for (int fetched = 0; fetched < maxPages; fetched++) {
      final PaginatedResult<CompanyModel> page = await _companies(role, query);
      all.addAll(page.items);

      // An empty page ends the walk whatever the pagination block claims:
      // without this a `total_pages` that overcounts spins until [maxPages].
      if (page.items.isEmpty || !page.pagination.hasNextPage) {
        return CompanyPage(companies: all, isComplete: true);
      }

      query = <String, dynamic>{...query, 'page': page.pagination.nextPage};
    }

    return CompanyPage(companies: all, isComplete: false);
  }

  Future<PaginatedResult<CompanyModel>> list(
    UserRole role,
    ListQuery query,
  ) =>
      _companies(role, query.toQueryParameters());

  /// The one place a company list is fetched and parsed.
  Future<PaginatedResult<CompanyModel>> _companies(
    UserRole role,
    Map<String, dynamic> query,
  ) async {
    final ApiResponse<PaginatedResult<CompanyModel>> response =
        await _api.get<PaginatedResult<CompanyModel>>(
      ApiEndpoints.companies(role),
      query: query,
      parser: (Object? data) => PaginatedResult<CompanyModel>.fromData(
        data,
        itemsKey: 'companies',
        parser: CompanyModel.fromJson,
      ),
    );
    return response.data!;
  }
}

/// The result of walking every page of the company list.
///
/// [isComplete] is false only when the walk hit its page cap, which means the
/// caller is holding a prefix of the list rather than all of it. Worth showing:
/// a picker missing companies looks the same as a picker with none missing.
class CompanyPage {
  const CompanyPage({required this.companies, required this.isComplete});

  final List<CompanyModel> companies;
  final bool isComplete;
}
