import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../models/invoice.dart';
import '../../../../providers/client_provider.dart';
import '../../../../providers/invoice_provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../utils/format.dart';
import '../../main_actions.dart';

/// One invoice row, used on the dashboard and in the invoice list.
class InvoiceListTile extends StatelessWidget {
  final Invoice invoice;

  const InvoiceListTile({super.key, required this.invoice});

  static Color statusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return AppTheme.textSecondaryColor;
      case InvoiceStatus.sent:
        return AppTheme.accentColor;
      case InvoiceStatus.paid:
        return AppTheme.secondaryColor;
      case InvoiceStatus.overdue:
        return AppTheme.errorColor;
      case InvoiceStatus.cancelled:
        return AppTheme.textTertiaryColor;
    }
  }

  Future<void> _onAction(BuildContext context, String action) async {
    final provider = context.read<InvoiceProvider>();
    switch (action) {
      case 'mark_paid':
        await provider.markAsPaid(invoice.id);
        break;
      case 'mark_unpaid':
        await provider
            .updateInvoice(invoice.copyWith(status: InvoiceStatus.sent));
        break;
      case 'cancel':
        if (await _confirm(
            context, 'cancel_invoice'.tr, 'cancel_invoice_hint'.tr)) {
          await provider
              .updateInvoice(invoice.copyWith(status: InvoiceStatus.cancelled));
        }
        break;
      case 'delete':
        if (context.mounted &&
            await _confirm(
                context, 'delete_draft'.tr, 'delete_draft_hint'.tr)) {
          await provider.deleteInvoice(invoice.id);
        }
        break;
    }
  }

  Future<bool> _confirm(
      BuildContext context, String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('cancel'.tr)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('confirm'.tr,
                style: const TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final client =
        context.watch<ClientProvider>().getClientById(invoice.clientId);
    final color = statusColor(invoice.status);
    final isDraft = invoice.status == InvoiceStatus.draft;
    final isOpen = invoice.status == InvoiceStatus.sent ||
        invoice.status == InvoiceStatus.overdue;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => openInvoice(context, invoice),
        title: Text(
          client?.name ?? '—',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: invoice.status == InvoiceStatus.cancelled
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Text(
          '${isDraft ? 'status_draft'.tr : invoice.invoiceNumber} · ${formatDate(invoice.issueDate)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatEuro(invoice.total),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                Text(
                  'status_${invoice.status.name}'.tr,
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (action) => _onAction(context, action),
              itemBuilder: (context) => [
                if (isOpen)
                  PopupMenuItem(
                      value: 'mark_paid', child: Text('mark_as_paid'.tr)),
                if (invoice.status == InvoiceStatus.paid)
                  PopupMenuItem(
                      value: 'mark_unpaid', child: Text('mark_as_unpaid'.tr)),
                if (isOpen)
                  PopupMenuItem(
                      value: 'cancel', child: Text('cancel_invoice'.tr)),
                if (isDraft)
                  PopupMenuItem(
                      value: 'delete', child: Text('delete_draft'.tr)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
