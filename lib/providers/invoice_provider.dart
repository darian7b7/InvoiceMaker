import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../services/storage_service.dart';

class InvoiceProvider extends ChangeNotifier {
  List<Invoice> _invoices = [];
  bool _isLoading = false;
  String? _error;

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  List<Invoice> get draftInvoices => _invoices
      .where((invoice) => invoice.status == InvoiceStatus.draft)
      .toList();

  List<Invoice> get sentInvoices => _invoices
      .where((invoice) => invoice.status == InvoiceStatus.sent)
      .toList();

  List<Invoice> get paidInvoices => _invoices
      .where((invoice) => invoice.status == InvoiceStatus.paid)
      .toList();

  List<Invoice> get overdueInvoices => _invoices
      .where((invoice) => invoice.status == InvoiceStatus.overdue)
      .toList();

  /// Invoices paid in [year], counted by payment date (Zuflussprinzip).
  List<Invoice> paidInYear(int year) => paidInvoices
      .where((invoice) => (invoice.paidAt ?? invoice.updatedAt).year == year)
      .toList();

  /// Sent but not yet paid (gross).
  double get pendingAmount => [...sentInvoices, ...overdueInvoices]
      .fold(0.0, (sum, invoice) => sum + invoice.total);

  Future<void> loadInvoices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final invoicesData = await StorageService.instance.getInvoices();
      _invoices = invoicesData.map((data) => Invoice.fromJson(data)).toList();
      _invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = 'Failed to load invoices: ${e.toString()}';
      debugPrint('Error loading invoices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createInvoice(Invoice invoice) async {
    try {
      _error = null;
      _invoices.insert(0, invoice);
      await _saveInvoices();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create invoice: ${e.toString()}';
      debugPrint('Error creating invoice: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateInvoice(Invoice updatedInvoice) async {
    try {
      _error = null;
      final index =
          _invoices.indexWhere((invoice) => invoice.id == updatedInvoice.id);
      if (index != -1) {
        _invoices[index] = updatedInvoice.copyWith(updatedAt: DateTime.now());
        await _saveInvoices();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update invoice: ${e.toString()}';
      debugPrint('Error updating invoice: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    try {
      _error = null;
      _invoices.removeWhere((invoice) => invoice.id == invoiceId);
      await _saveInvoices();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete invoice: ${e.toString()}';
      debugPrint('Error deleting invoice: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markAsPaid(String invoiceId) async {
    try {
      final index = _invoices.indexWhere((invoice) => invoice.id == invoiceId);
      if (index != -1) {
        _invoices[index] = _invoices[index].copyWith(
          status: InvoiceStatus.paid,
          paidAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _saveInvoices();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking invoice as paid: $e');
      rethrow;
    }
  }

  Future<void> sendInvoice(String invoiceId) async {
    try {
      final index = _invoices.indexWhere((invoice) => invoice.id == invoiceId);
      if (index != -1) {
        _invoices[index] = _invoices[index].copyWith(
          status: InvoiceStatus.sent,
          updatedAt: DateTime.now(),
        );
        await _saveInvoices();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error sending invoice: $e');
      rethrow;
    }
  }

  String generateInvoiceNumber() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final count = _invoices.length + 1;
    return 'INV-$year$month-${count.toString().padLeft(3, '0')}';
  }

  Future<void> _saveInvoices() async {
    final invoicesData = _invoices.map((invoice) => invoice.toJson()).toList();
    await StorageService.instance.saveInvoices(invoicesData);
  }

  List<Invoice> searchInvoices(String query) {
    if (query.isEmpty) return _invoices;

    final lowercaseQuery = query.toLowerCase();
    return _invoices.where((invoice) {
      return invoice.invoiceNumber.toLowerCase().contains(lowercaseQuery) ||
          invoice.notes?.toLowerCase().contains(lowercaseQuery) == true;
    }).toList();
  }
}
