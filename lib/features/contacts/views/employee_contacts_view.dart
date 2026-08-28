import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/widgets/paged_list_view.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/controllers/employee_contacts_controller.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/data/models/contact_model.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/widgets/contact_card.dart';

/// The contact book for an employee — read-only, and only what the
/// `/employee/contacts` router returns for them.
class EmployeeContactsView extends GetView<EmployeeContactsController> {
  const EmployeeContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        bottom: ListSearchBar(
          hintText: 'Search contacts',
          onChanged: controller.search,
        ),
      ),
      body: PagedListView<ContactModel>(
        controller: controller,
        loadingMessage: 'Loading contacts…',
        emptyTitle: 'No contacts yet',
        emptyMessage: 'Nobody matched this search.',
        emptyIcon: Icons.contacts_outlined,
        totalLabel: 'contacts',
        itemBuilder: (BuildContext context, ContactModel contact) =>
            ContactCard(
          contact: contact,
          onTap: () => controller.openContact(contact),
        ),
      ),
    );
  }
}
