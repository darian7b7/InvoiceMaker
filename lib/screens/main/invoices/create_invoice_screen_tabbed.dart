import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../models/invoice.dart';
import '../../../providers/business_provider.dart';
import '../../../providers/invoice_provider.dart';
import '../../../theme/app_theme.dart';
import 'widgets/invoice_form_tab.dart';
import 'widgets/invoice_preview_tab.dart';

/// Creates or edits a draft invoice. Issued invoices are shown read-only:
/// German bookkeeping rules (GoBD) require cancelling them instead of editing.
class CreateInvoiceScreenTabbed extends StatefulWidget {
  final Invoice? invoice;
  final int initialTabIndex;

  const CreateInvoiceScreenTabbed({
    super.key,
    this.invoice,
    this.initialTabIndex = 0,
  });

  @override
  State<CreateInvoiceScreenTabbed> createState() =>
      _CreateInvoiceScreenTabbedState();
}

class _CreateInvoiceScreenTabbedState extends State<CreateInvoiceScreenTabbed>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  late Invoice _currentInvoice;

  bool get _isEditable =>
      widget.invoice == null || widget.invoice!.status == InvoiceStatus.draft;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    final now = DateTime.now();
    _currentInvoice = widget.invoice ??
        Invoice(
          id: now.microsecondsSinceEpoch.toString(),
          clientId: '',
          invoiceNumber: 'DRAFT',
          issueDate: now,
          dueDate: now.add(const Duration(days: 14)),
          items: [],
          subtotal: 0,
          taxRate: 0,
          taxAmount: 0,
          total: 0,
          status: InvoiceStatus.draft,
          createdAt: now,
          updatedAt: now,
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onInvoiceChanged(Invoice updatedInvoice) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _currentInvoice = updatedInvoice);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    _tabController.animateTo(0);
  }

  Future<void> _save({required bool issue}) async {
    // The form is only built once its tab has been shown.
    if (_formKey.currentState?.validate() == false) {
      _tabController.animateTo(0);
      return;
    }
    if (_currentInvoice.clientId.isEmpty) return _showError('select_client'.tr);
    if (_currentInvoice.items.isEmpty ||
        _currentInvoice.items.any((item) => item.description.trim().isEmpty)) {
      return _showError('add_one_item'.tr);
    }

    // Numbers are only assigned when issuing, so they stay gap-free.
    final invoice = _currentInvoice.copyWith(
      invoiceNumber: issue
          ? await context
              .read<BusinessProvider>()
              .generateAndIncrementInvoiceNumber()
          : 'DRAFT',
      status: issue ? InvoiceStatus.sent : InvoiceStatus.draft,
      updatedAt: DateTime.now(),
    );
    if (!mounted) return;

    final invoiceProvider = context.read<InvoiceProvider>();
    if (widget.invoice != null) {
      await invoiceProvider.updateInvoice(invoice);
    } else {
      await invoiceProvider.createInvoice(invoice);
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(issue ? 'invoice_issued'.tr : 'draft_saved'.tr)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isEditable) {
      return Scaffold(
        appBar: AppBar(title: Text(_currentInvoice.invoiceNumber)),
        body: InvoicePreviewTab(invoice: _currentInvoice),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.invoice == null ? 'new_invoice'.tr : 'edit_draft'.tr),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.edit), text: 'edit'.tr),
            Tab(icon: const Icon(Icons.preview), text: 'preview'.tr),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          InvoiceFormTab(
            formKey: _formKey,
            onInvoiceChanged: _onInvoiceChanged,
            currentInvoice: _currentInvoice,
          ),
          InvoicePreviewTab(invoice: _currentInvoice),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _save(issue: false),
                  child: Text('save_draft'.tr),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _save(issue: true),
                  child: Text('issue_invoice'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
