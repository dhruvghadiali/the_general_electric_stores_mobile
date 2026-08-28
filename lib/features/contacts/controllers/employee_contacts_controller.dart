import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/controllers/base_list_controller.dart';
import 'package:the_general_electric_stores_mobile/core/models/list_query.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_response.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/data/models/contact_model.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/data/repositories/contact_repository.dart';

/// Contacts as an employee sees them — whatever `/employee/contacts` returns,
/// read-only. Whether that is every contact or only the ones assigned to them
/// is the server's decision, not a filter applied here.
class EmployeeContactsController extends BaseListController<ContactModel> {
  EmployeeContactsController(this._repository, this.role);

  final ContactRepository _repository;
  final UserRole role;

  @override
  Future<PaginatedResult<ContactModel>> fetchPage(ListQuery query) =>
      _repository.list(role, query);

  void openContact(ContactModel contact) =>
      Get.toNamed<void>(AppRoutes.contactDetailPath(contact.id));

  void sortByName() => sortBy('name');

  void sortByNewest() => sortBy('created_at', order: SortOrder.desc);
}
