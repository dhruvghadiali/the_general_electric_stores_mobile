import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/widgets/paged_list_view.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/controllers/super_admin_contacts_controller.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/data/models/contact_model.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/widgets/contact_card.dart';

/// The contact book for a super admin, with the create action.
class SuperAdminContactsView extends GetView<SuperAdminContactsController> {
  const SuperAdminContactsView({super.key});

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
      floatingActionButton: controller.canCreate
          ? FloatingActionButton.extended(
              heroTag: 'fab_super_admin_contacts',
              onPressed: controller.createContact,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Add contact'),
            )
          : null,
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
