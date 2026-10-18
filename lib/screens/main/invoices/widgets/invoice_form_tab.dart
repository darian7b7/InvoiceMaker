import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../models/client.dart';
import '../../../../models/invoice.dart';
import '../../../../providers/business_provider.dart';
import '../../../../providers/client_provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../utils/format.dart';
import 'client_selector_widget.dart';

class InvoiceFormTab extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(Invoice) onInvoiceChanged;
  final Invoice currentInvoice;

  const InvoiceFormTab({
    super.key,
    required this.formKey,
    required this.onInvoiceChanged,
    required this.currentInvoice,
  });

  @override
  State<InvoiceFormTab> createState() => _InvoiceFormTabState();
}

class _InvoiceFormTabState extends State<InvoiceFormTab> {
  final _notesController = TextEditingController();

  Client? _selectedClient;
  late DateTime _issueDate;
  DateTime? _serviceDate;
  late DateTime _dueDate;
  late double _taxRate;
  late bool _isKleinunternehmer;
  List<InvoiceItem> _items = [];

  @override
  void initState() {
    super.initState();
    final invoice = widget.currentInvoice;
    _isKleinunternehmer =
        context.read<BusinessProvider>().business?.isKleinunternehmer ?? false;
    _selectedClient =
        context.read<ClientProvider>().getClientById(invoice.clientId);
    _issueDate = invoice.issueDate;
    _serviceDate = invoice.serviceDate;
    _dueDate = invoice.dueDate;
    _taxRate = _isKleinunternehmer
        ? 0
        : (invoice.items.isEmpty ? 19 : invoice.taxRate);
    _notesController.text = invoice.notes ?? '';
    _items =
        invoice.items.map((i) => i.copyWith(unit: unitCode(i.unit))).toList();

    if (_items.isEmpty) {
      _addItem();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(InvoiceItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        description: '',
        quantity: 1,
        unitPrice: 0,
        total: 0,
      ));
    });
    _updateInvoice();
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
    _updateInvoice();
  }

  void _updateItem(int index, InvoiceItem Function(InvoiceItem) change) {
    setState(() => _items[index] = change(_items[index]));
    _updateInvoice();
  }

  double _itemTotal(InvoiceItem item) =>
      roundCents(item.quantity * item.unitPrice);
  double get _subtotal =>
      roundCents(_items.fold(0.0, (sum, item) => sum + _itemTotal(item)));
  double get _taxAmount => roundCents(_subtotal * _taxRate / 100);
  double get _total => roundCents(_subtotal + _taxAmount);

  void _updateInvoice() {
    widget.onInvoiceChanged(widget.currentInvoice.copyWith(
      clientId: _selectedClient?.id ?? '',
      issueDate: _issueDate,
      serviceDate: _serviceDate,
      dueDate: _dueDate,
      items:
          _items.map((item) => item.copyWith(total: _itemTotal(item))).toList(),
      subtotal: _subtotal,
      taxRate: _taxRate,
      taxAmount: _taxAmount,
      total: _total,
      notes: _notesController.text,
      updatedAt: DateTime.now(),
    ));
  }

  Future<DateTime?> _pickDate(DateTime initial) => showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

  Widget _dateField(String label, String value, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(labelText: label),
          child: Text(value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClientSelectorWidget(
              selectedClient: _selectedClient,
              onClientSelected: (client) {
                setState(() => _selectedClient = client);
                _updateInvoice();
              },
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                _dateField('invoice_date'.tr, formatDate(_issueDate), () async {
                  final picked = await _pickDate(_issueDate);
                  if (picked == null) return;
                  setState(() => _issueDate = picked);
                  _updateInvoice();
                }),
                const SizedBox(width: AppTheme.spacingM),
                _dateField(
                  'service_date'.tr,
                  _serviceDate == null
                      ? 'same_as_invoice_date'.tr
                      : formatDate(_serviceDate!),
                  () async {
                    final picked = await _pickDate(_serviceDate ?? _issueDate);
                    if (picked == null) return;
                    setState(() => _serviceDate = picked);
                    _updateInvoice();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                _dateField('due_date'.tr, formatDate(_dueDate), () async {
                  final picked = await _pickDate(_dueDate);
                  if (picked == null) return;
                  setState(() => _dueDate = picked);
                  _updateInvoice();
                }),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: _isKleinunternehmer
                      ? InputDecorator(
                          decoration: InputDecoration(labelText: 'vat'.tr),
                          child: Text('kleinunternehmer_short'.tr),
                        )
                      : DropdownButtonFormField<double>(
                          initialValue:
                              vatRates.contains(_taxRate) ? _taxRate : 19,
                          decoration: InputDecoration(labelText: 'vat'.tr),
                          items: vatRates
                              .map((rate) => DropdownMenuItem(
                                    value: rate,
                                    child: Text('${rate.toStringAsFixed(0)} %'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _taxRate = value!);
                            _updateInvoice();
                          },
                        ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('invoice_items'.tr,
                    style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: Text('add_item'.tr),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            for (var index = 0; index < _items.length; index++)
              _buildItemCard(index),
            Card(
              margin: const EdgeInsets.only(top: AppTheme.spacingS),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  children: [
                    _totalRow('net_amount'.tr, _subtotal),
                    if (!_isKleinunternehmer)
                      _totalRow('${'vat'.tr} ${_taxRate.toStringAsFixed(0)} %',
                          _taxAmount),
                    const Divider(),
                    _totalRow('total'.tr, _total, bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(labelText: 'notes_optional'.tr),
              maxLines: 3,
              onChanged: (_) => _updateInvoice(),
            ),
            const SizedBox(height: AppTheme.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = _items[index];
    return Card(
      key: ValueKey(item.id),
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            TextFormField(
              initialValue: item.description,
              decoration: InputDecoration(labelText: 'description'.tr),
              onChanged: (value) =>
                  _updateItem(index, (i) => i.copyWith(description: value)),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'required'.tr : null,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: formatQuantity(item.quantity),
                    decoration: InputDecoration(labelText: 'quantity'.tr),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) => _updateItem(index,
                        (i) => i.copyWith(quantity: parseAmount(value) ?? 0)),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: item.unit,
                    decoration: InputDecoration(labelText: 'unit'.tr),
                    items: invoiceUnits.entries
                        .map((unit) => DropdownMenuItem(
                              value: unit.key,
                              child:
                                  Text(unit.value.isEmpty ? '—' : unit.value),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        _updateItem(index, (i) => i.copyWith(unit: value)),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: TextFormField(
                    initialValue: item.unitPrice == 0
                        ? ''
                        : item.unitPrice
                            .toStringAsFixed(2)
                            .replaceAll('.', ','),
                    decoration: InputDecoration(
                        labelText: 'unit_price_net'.tr, suffixText: '€'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) => _updateItem(index,
                        (i) => i.copyWith(unitPrice: parseAmount(value) ?? 0)),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed:
                      _items.length > 1 ? () => _removeItem(index) : null,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'delete'.tr,
                ),
                Text(
                  formatEuro(_itemTotal(item)),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, double amount, {bool bold = false}) {
    final style = bold
        ? Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            )
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(formatEuro(amount), style: style),
        ],
      ),
    );
  }
}
