import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/controllers/base_detail_controller.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/data/models/contact_model.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/data/repositories/contact_repository.dart';

class ContactDetailController extends BaseDetailController<ContactModel> {
  ContactDetailController(this._repository);

  final ContactRepository _repository;

  ContactModel? get contact => item.value;

  @override
  Future<ContactModel> fetch(UserRole role, String id) =>
      _repository.byId(role, id);
}
