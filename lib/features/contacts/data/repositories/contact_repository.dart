import 'package:the_general_electric_stores_mobile/core/constants/api_endpoints.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/models/list_query.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_client.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_response.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/data/models/contact_model.dart';

/// Company contacts, scoped to the signed-in role.
///
/// Super admin and employee both read them, but through their own routers —
/// `/super-admin/company-contacts` and `/employee/company-contacts`. The server
/// decides what each sees; the client cannot even build the other role's path,
/// because the role comes from the session.
///
/// [byId] has no route behind it yet: neither router mounts a GET on `/:id`,
/// only the list. It will answer 404 until the API adds one.
class ContactRepository {
  const ContactRepository(this._api);

  final ApiClient _api;

  Future<PaginatedResult<ContactModel>> list(
    UserRole role,
    ListQuery query,
  ) async {
    final ApiResponse<PaginatedResult<ContactModel>> response =
        await _api.get<PaginatedResult<ContactModel>>(
      ApiEndpoints.companyContacts(role),
      query: query.toQueryParameters(),
      parser: (Object? data) => PaginatedResult<ContactModel>.fromData(
        data,
        // `send_response(res, OK, LISTED, { company_contacts, summary, sort,
        // pagination })` — the rows key is the API's, not ours.
        itemsKey: 'company_contacts',
        parser: ContactModel.fromJson,
      ),
    );
    return response.data!;
  }

  Future<ContactModel> byId(UserRole role, String id) async {
    final ApiResponse<ContactModel> response = await _api.get<ContactModel>(
      ApiEndpoints.companyContact(role, id),
      parser: (Object? data) => ContactModel.fromJson(firstObject(data)),
    );
    return response.data!;
  }
}
