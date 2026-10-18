import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../../models/client.dart';
import '../../../../providers/client_provider.dart';
import '../../../../services/contacts_service.dart';

class ClientSelectorWidget extends StatefulWidget {
  final Client? selectedClient;
  final Function(Client?) onClientSelected;

  const ClientSelectorWidget({
    super.key,
    this.selectedClient,
    required this.onClientSelected,
  });

  @override
  State<ClientSelectorWidget> createState() => _ClientSelectorWidgetState();
}

class _ClientSelectorWidgetState extends State<ClientSelectorWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _showDropdown = false;
  List<Client> _filteredClients = [];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.selectedClient?.name ?? '';
    _updateFilteredClients();
  }

  void _updateFilteredClients() {
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredClients = clientProvider.clients;
      } else {
        _filteredClients = clientProvider.clients.where((client) {
          return client.name.toLowerCase().contains(query) ||
              client.email.toLowerCase().contains(query) ||
              client.phone.contains(query);
        }).toList();
      }
    });
  }

  void _showContactPicker() async {
    try {
      final contacts = await ContactsService.instance.getPhoneContacts();
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ContactPickerSheet(
          contacts: contacts,
          onContactSelected: (contact) {
            final client = ContactsService.instance.contactToClient(contact);
            _showClientFormDialog(client);
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('contacts_failed'.tr),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showClientFormDialog([Client? client]) {
    showDialog(
      context: context,
      builder: (context) => ClientFormDialog(
        client: client,
        onClientSaved: (savedClient) {
          widget.onClientSelected(savedClient);
          setState(() {
            _searchController.text = savedClient.name;
            _showDropdown = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'client'.tr,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'search_or_select_client'.tr,
                  prefixIcon: const Icon(Icons.person_outline),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!kIsWeb)
                        IconButton(
                          icon: const Icon(Icons.contacts),
                          onPressed: _showContactPicker,
                          tooltip: 'import_from_contacts'.tr,
                        ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _showClientFormDialog(),
                        tooltip: 'new_client'.tr,
                      ),
                      IconButton(
                        icon: Icon(_showDropdown
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down),
                        onPressed: () {
                          setState(() {
                            _showDropdown = !_showDropdown;
                          });
                        },
                      ),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                onChanged: (value) {
                  _updateFilteredClients();
                  setState(() {
                    _showDropdown =
                        value.isNotEmpty || _filteredClients.isNotEmpty;
                  });
                },
                onTap: () {
                  setState(() {
                    _showDropdown = true;
                  });
                },
              ),
              if (_showDropdown && _filteredClients.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredClients.length,
                    itemBuilder: (context, index) {
                      final client = _filteredClients[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            client.name.isNotEmpty
                                ? client.name[0].toUpperCase()
                                : 'C',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(client.name),
                        subtitle: Text(client.email.isNotEmpty
                            ? client.email
                            : client.phone),
                        onTap: () {
                          widget.onClientSelected(client);
                          setState(() {
                            _searchController.text = client.name;
                            _showDropdown = false;
                          });
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ContactPickerSheet extends StatefulWidget {
  final List<Contact> contacts;
  final Function(Contact) onContactSelected;

  const ContactPickerSheet({
    super.key,
    required this.contacts,
    required this.onContactSelected,
  });

  @override
  State<ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<ContactPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.contacts;
  }

  void _filterContacts(String query) {
    setState(() {
      _filteredContacts = ContactsService.instance.searchContacts(
        widget.contacts,
        query,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.contacts, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Select Contact',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'search_contacts'.tr,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: _filterContacts,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = _filteredContacts[index];
                final phone = contact.phones.isNotEmpty
                    ? contact.phones.first.number
                    : '';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      contact.displayName.isNotEmpty
                          ? contact.displayName[0].toUpperCase()
                          : 'C',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(contact.displayName.isNotEmpty
                      ? contact.displayName
                      : 'Unknown Contact'),
                  subtitle: Text(phone),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onContactSelected(contact);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ClientFormDialog extends StatefulWidget {
  final Client? client;
  final Function(Client) onClientSaved;

  const ClientFormDialog({
    super.key,
    this.client,
    required this.onClientSaved,
  });

  @override
  State<ClientFormDialog> createState() => _ClientFormDialogState();
}

class _ClientFormDialogState extends State<ClientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool get _isEditing => widget.client?.id.isNotEmpty == true;

  @override
  void initState() {
    super.initState();
    final client = widget.client;
    _nameController = TextEditingController(text: client?.name ?? '');
    _companyController = TextEditingController(text: client?.company ?? '');
    _addressController = TextEditingController(text: client?.address ?? '');
    _cityController = TextEditingController(text: client?.city ?? '');
    _emailController = TextEditingController(text: client?.email ?? '');
    _phoneController = TextEditingController(text: client?.phone ?? '');
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    final client = Client(
      id: widget.client?.id ?? '',
      name: _nameController.text.trim(),
      company: _companyController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      country: widget.client?.country ?? '',
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      projects: widget.client?.projects ?? [],
      createdAt: widget.client?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final clientProvider = context.read<ClientProvider>();
      final savedClient = _isEditing
          ? await clientProvider.updateClient(client)
          : await clientProvider.createClient(client);

      if (mounted) {
        Navigator.pop(context);
        widget.onClientSaved(savedClient);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('error_saving_client'.tr),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _field(TextEditingController controller, String label,
      {bool required = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: required ? '$label *' : label),
        validator: required
            ? (value) =>
                value == null || value.trim().isEmpty ? 'required'.tr : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'edit_client'.tr : 'new_client'.tr),
      // Fixed width: AlertDialog otherwise shrinks to its content and clips labels.
      content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(_nameController, 'client_name'.tr, required: true),
                  _field(_companyController, 'company'.tr),
                  _field(_addressController, 'street_address'.tr,
                      required: true),
                  _field(_cityController, 'postcode_city'.tr, required: true),
                  _field(_emailController, 'email'.tr,
                      keyboardType: TextInputType.emailAddress),
                  _field(_phoneController, 'phone'.tr,
                      keyboardType: TextInputType.phone),
                ],
              ),
            ),
          )),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text('cancel'.tr)),
        ElevatedButton(onPressed: _saveClient, child: Text('save'.tr)),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
