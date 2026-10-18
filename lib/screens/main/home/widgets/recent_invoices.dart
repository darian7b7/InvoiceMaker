import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../providers/invoice_provider.dart';
import '../../../../theme/app_theme.dart';
import '../../invoices/widgets/invoice_list_tile.dart';
import '../../main_actions.dart';

class RecentInvoices extends StatelessWidget {
  const RecentInvoices({super.key});

  @override
  Widget build(BuildContext context) {
    final recentInvoices =
        context.watch<InvoiceProvider>().invoices.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'recent_invoices'.tr,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppTheme.spacingM),
        if (recentInvoices.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: ElevatedButton.icon(
                onPressed: () => openCreateInvoice(context),
                icon: const Icon(Icons.add),
                label: Text('new_invoice'.tr),
              ),
            ),
          )
        else
          for (final invoice in recentInvoices) ...[
            InvoiceListTile(invoice: invoice),
            const SizedBox(height: AppTheme.spacingS),
          ],
      ],
    );
  }
}
