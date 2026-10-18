import 'package:flutter/material.dart';
import '../../models/client.dart';
import '../../models/invoice.dart';
import 'expenses/expense_dialog.dart';
import 'invoices/create_invoice_screen_tabbed.dart';
import 'invoices/widgets/client_selector_widget.dart';

/// Shared entry points used by buttons across the main screens.
void openCreateInvoice(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const CreateInvoiceScreenTabbed()),
  );
}

void openInvoice(BuildContext context, Invoice invoice) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => CreateInvoiceScreenTabbed(
        invoice: invoice,
        // Drafts open for editing; issued invoices only show the PDF.
        initialTabIndex: invoice.status == InvoiceStatus.draft ? 0 : 1,
      ),
    ),
  );
}

/// Opens the client form; edits [client] when given, otherwise adds a new one.
void openAddClient(BuildContext context, [Client? client]) {
  showDialog(
    context: context,
    builder: (_) => ClientFormDialog(client: client, onClientSaved: (_) {}),
  );
}

void openAddExpense(BuildContext context) {
  showDialog(context: context, builder: (_) => const ExpenseDialog());
}
