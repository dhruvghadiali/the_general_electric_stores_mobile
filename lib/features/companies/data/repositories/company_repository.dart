import 'package:the_general_electric_stores_mobile/core/constants/api_endpoints.dart';
import 'package:the_general_electric_stores_mobile/core/constants/app_constants.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/models/list_query.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_client.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_response.dart';
import 'package:the_general_electric_stores_mobile/features/companies/data/models/company_model.dart';

/// Companies, scoped to the signed-in role's router.
///
/// ```
/// GET /warehouse-manager/companies
///     ?is_active=true&sort=company_name:asc&page=1&limit=20
/// ```
///
/// All three roles may list companies; only an employee may read one or write
/// any, so this repository is a list and nothing else.
class CompanyRepository {
  const CompanyRepository(this._api);

  final ApiClient _api;

  /// The query behind every company picker: live companies only, in the order
  /// a person reads them.
  ///
  /// `sort` rather than `sort_by`/`sort_order` — the API accepts both but makes
  /// them mutually exclusive (`.oxor`), and the single-token form is the one
  /// that cannot fall out of step with itself. `company_name` is also the only
  /// company column the API gives English collation to, so `acme` sorts before
  /// `Bharat` instead of after it.
  static const ListQuery activePickerQuery = ListQuery(
    page: AppConstants.defaultPage,
    limit: AppConstants.defaultPageLimit,
    sort: <String>['company_name:asc'],
    filters: <String, dynamic>{'is_active': true},
  );

  /// Every active company, gathered a page at a time.
  ///
  /// A picker needs the whole list, and the API's page size is 20. Asking for
  /// `limit=100` in one shot would work today and break silently on the
  /// hundred-and-first company, so this follows `pagination.total_pages`
  /// instead — the first request is exactly [activePickerQuery], and each
  /// further page is the same query with `page` advanced.
  ///
  /// [maxPages] is a stop, not a page size. A dropdown holding five hundred
  /// companies is the wrong control regardless of how patiently it loaded them,
  /// and the cap is what stops a wrong `total_pages` fetching forever. Reaching
  /// it is reported rather than hidden — see [CompanyPage.isComplete].
  Future<CompanyPage> activeCompanies(UserRole role, {int maxPages = 25}) async {
    final List<CompanyModel> all = <CompanyModel>[];
    ListQuery query = activePickerQuery;

    for (int fetched = 0; fetched < maxPages; fetched++) {
      final PaginatedResult<CompanyModel> page = await list(role, query);
      all.addAll(page.items);

      // An empty page ends the walk whatever the pagination block claims:
      // without this a `total_pages` that overcounts spins until [maxPages].
      if (page.items.isEmpty || !page.pagination.hasNextPage) {
        return CompanyPage(companies: all, isComplete: true);
      }

      query = query.copyWith(page: page.pagination.nextPage);
    }

    return CompanyPage(companies: all, isComplete: false);
  }

  Future<PaginatedResult<CompanyModel>> list(
    UserRole role,
    ListQuery query,
  ) async {
    final ApiResponse<PaginatedResult<CompanyModel>> response =
        await _api.get<PaginatedResult<CompanyModel>>(
      ApiEndpoints.companies(role),
      query: query.toQueryParameters(),
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
