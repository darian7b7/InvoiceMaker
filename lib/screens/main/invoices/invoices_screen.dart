import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../models/invoice.dart';
import '../../../providers/invoice_provider.dart';
import '../../../theme/app_theme.dart';
import '../main_actions.dart';
import 'widgets/invoice_list_tile.dart';

enum _Filter { all, open, paid, drafts }

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  _Filter _filter = _Filter.all;

  bool _matches(Invoice invoice) {
    switch (_filter) {
      case _Filter.all:
        return true;
      case _Filter.open:
        return invoice.status == InvoiceStatus.sent ||
            invoice.status == InvoiceStatus.overdue;
      case _Filter.paid:
        return invoice.status == InvoiceStatus.paid;
      case _Filter.drafts:
        return invoice.status == InvoiceStatus.draft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allInvoices = context.watch<InvoiceProvider>().invoices;

    if (allInvoices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 64, color: AppTheme.textTertiaryColor),
              const SizedBox(height: AppTheme.spacingM),
              Text('no_invoices_yet'.tr,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppTheme.spacingL),
              ElevatedButton.icon(
                onPressed: () => openCreateInvoice(context),
                icon: const Icon(Icons.add),
                label: Text('new_invoice'.tr),
              ),
            ],
          ),
        ),
      );
    }

    final invoices = allInvoices.where(_matches).toList();

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: _Filter.values
                .map((filter) => Padding(
                      padding: const EdgeInsets.only(right: AppTheme.spacingS),
                      child: ChoiceChip(
                        label: Text('filter_${filter.name}'.tr),
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                      ),
                    ))
                .toList(),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingM, 0, AppTheme.spacingM, 88),
            itemCount: invoices.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppTheme.spacingS),
            itemBuilder: (context, index) =>
                InvoiceListTile(invoice: invoices[index]),
          ),
        ),
      ],
    );
  }
}
