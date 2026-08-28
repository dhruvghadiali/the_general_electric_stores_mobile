import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/utils/formatters.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/state_views.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/controllers/contact_detail_controller.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/data/models/contact_model.dart';

class ContactDetailView extends GetView<ContactDetailController> {
  const ContactDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Contact')),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingView();

        if (controller.failure.value != null) {
          return ErrorView(
            error: controller.failure.value!,
            onRetry: controller.load,
          );
        }

        final ContactModel? contact = controller.contact;
        if (contact == null) {
          return const EmptyView(title: 'This contact is no longer available');
        }

        return ListView(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Text(
                    contact.initials,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(contact.name, style: theme.textTheme.titleMedium),
                      if (contact.company != null) ...<Widget>[
                        const SizedBox(height: AppDimens.xxs),
                        Text(
                          contact.company!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.xl),
            const Divider(),
            _Row(label: 'Type', value: contact.type ?? '—'),
            _Row(label: 'Email', value: contact.email ?? '—'),
            _Row(label: 'Mobile', value: contact.phone ?? '—'),
            _Row(
              label: 'Location',
              value: contact.location.isEmpty ? '—' : contact.location,
            ),
            _Row(
              label: 'Added',
              value: Formatters.date(contact.createdAt),
            ),
          ],
        );
      }),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
