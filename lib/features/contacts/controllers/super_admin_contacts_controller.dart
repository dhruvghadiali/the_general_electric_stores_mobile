import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/controllers/base_list_controller.dart';
import 'package:the_general_electric_stores_mobile/core/models/list_query.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_response.dart';
import 'package:the_general_electric_stores_mobile/core/utils/app_snackbar.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/data/models/contact_model.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/data/repositories/contact_repository.dart';

/// The whole contact book, with the actions only a super admin has.
class SuperAdminContactsController extends BaseListController<ContactModel> {
  SuperAdminContactsController(this._repository, this.role);

  final ContactRepository _repository;
  final UserRole role;

  bool get canCreate => true;

  @override
  Future<PaginatedResult<ContactModel>> fetchPage(ListQuery query) =>
      _repository.list(role, query);

  void openContact(ContactModel contact) =>
      Get.toNamed<void>(AppRoutes.contactDetailPath(contact.id));

  void createContact() {
    // TODO(contacts): POST /super-admin/contacts once the form exists.
    AppSnackbar.info('Adding contacts is not built yet.');
  }

  void sortByName() => sortBy('name');

  void sortByNewest() => sortBy('created_at', order: SortOrder.desc);
}
