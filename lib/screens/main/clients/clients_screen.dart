import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../models/client.dart';
import '../../../providers/client_provider.dart';
import '../../../providers/invoice_provider.dart';
import '../../../theme/app_theme.dart';
import '../main_actions.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _searchQuery = '';

  Future<void> _confirmDelete(Client client) async {
    final hasInvoices = context
        .read<InvoiceProvider>()
        .invoices
        .any((invoice) => invoice.clientId == client.id);
    if (hasInvoices) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('client_has_invoices'.tr)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_client'.tr),
        content: Text(client.name),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('cancel'.tr)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('delete'.tr,
                style: const TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<ClientProvider>().deleteClient(client.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = context.watch<ClientProvider>();
    final clients = _searchQuery.isEmpty
        ? clientProvider.clients
        : clientProvider.searchClients(_searchQuery);

    if (clientProvider.clients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_outline,
                  size: 64, color: AppTheme.textTertiaryColor),
              const SizedBox(height: AppTheme.spacingM),
              Text('no_clients_yet'.tr,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppTheme.spacingL),
              ElevatedButton.icon(
                onPressed: () => openAddClient(context),
                icon: const Icon(Icons.add),
                label: Text('new_client'.tr),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'search_clients'.tr,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingM, 0, AppTheme.spacingM, 88),
            itemCount: clients.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppTheme.spacingS),
            itemBuilder: (context, index) {
              final client = clients[index];
              final details = [
                if (client.company?.isNotEmpty == true) client.company!,
                if (client.city.isNotEmpty) client.city,
              ].join(' · ');
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  onTap: () => openAddClient(context, client),
                  leading: CircleAvatar(
                    child: Text(client.name.isNotEmpty
                        ? client.name[0].toUpperCase()
                        : '?'),
                  ),
                  title: Text(client.name),
                  subtitle: details.isEmpty ? null : Text(details),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'delete'.tr,
                    onPressed: () => _confirmDelete(client),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
