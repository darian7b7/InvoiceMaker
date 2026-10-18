import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'business_provider.dart';
import 'client_provider.dart';
import 'expense_provider.dart';
import 'invoice_provider.dart';

/// Loads every provider from storage — at startup and after a backup restore.
Future<void> loadAppData(BuildContext context) async {
  await Future.wait([
    context.read<BusinessProvider>().loadBusinessData(),
    context.read<ClientProvider>().loadClients(),
    context.read<InvoiceProvider>().loadInvoices(),
    context.read<ExpenseProvider>().loadExpenses(),
  ]);
}
