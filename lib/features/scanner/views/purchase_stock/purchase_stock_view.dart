import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/app_dropdown_field.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/request_status_line/request_status_line.dart';
import 'package:the_general_electric_stores_mobile/features/companies/data/models/company_model.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/purchase_stock/purchase_stock_controller.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/controllers/purchase_stock/purchase_stock_status.dart';

/// Where "Purchase stock" lands: items arriving into the warehouse.
///
/// The supplier is asked for first because it is the one fact that scopes
/// everything after it — the list comes from the API already filtered to
/// `company_type=supplier`, so nothing a customer-only company owns can be
/// picked here by mistake.
///
/// The dropdown is on screen from the first frame, empty and disabled while the
/// list loads, with the request's own state reported underneath it. Nothing
/// moves when the suppliers arrive, and a failure reads as "this field has
/// nothing in it yet" rather than as a broken screen.
class PurchaseStockView extends GetView<PurchaseStockController> {
  const PurchaseStockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase stock'),
        leading: IconButton(
          onPressed: controller.cancel,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          children: <Widget>[
            Obx(
              () => AppDropdownField<CompanyModel>(
                key: ValueKey<String?>(controller.selectedCompanyId),
                label: 'Supplier',
                hint: controller.isLoading.value
                    ? 'Loading suppliers…'
                    : 'Choose a supplier',
                prefixIcon: Icons.domain_outlined,
                items: controller.suppliers,
                itemLabel: (CompanyModel company) => company.name,
                value: controller.selected.value,
                onChanged: controller.select,
                enabled: controller.canChoose,
              ),
            ),
            Obx(
              () => RequestStatusLine(
                isLoading: controller.isLoading.value,
                loadingMessage: 'Loading suppliers…',
                error: controller.failure.value,
                onRetry: controller.canRetry ? controller.load : null,
                note: controller.note,
                noteIcon: controller.noteIcon,
                noteTone: controller.isTruncated.value
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
