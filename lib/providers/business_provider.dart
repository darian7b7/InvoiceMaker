import 'package:flutter/material.dart';
import '../models/business.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class BusinessProvider extends ChangeNotifier {
  Business? _business;
  bool _isLoading = false;

  Business? get business => _business;
  bool get isLoading => _isLoading;
  bool get isBusinessRegistered => _business != null;

  Future<void> loadBusinessData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final businessData = await StorageService.instance.getBusinessData();
      if (businessData != null) {
        _business = Business.fromJson(businessData);
      }
    } catch (e) {
      debugPrint('Error loading business data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerBusiness({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String country,
    String? logoPath,
    String? taxId,
    bool isKleinunternehmer = false,
    String? bankName,
    String? iban,
    String? bic,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      _business = Business(
        id: const Uuid().v4(),
        name: name,
        email: email,
        phone: phone,
        address: address,
        city: city,
        country: country,
        logoPath: logoPath,
        taxId: taxId,
        isKleinunternehmer: isKleinunternehmer,
        bankName: bankName,
        iban: iban,
        bic: bic,
        createdAt: now,
        updatedAt: now,
      );

      await StorageService.instance.saveBusinessData(_business!.toJson());
    } catch (e) {
      debugPrint('Error registering business: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBusiness(Business updatedBusiness) async {
    _isLoading = true;
    notifyListeners();

    try {
      _business = updatedBusiness.copyWith(updatedAt: DateTime.now());
      await StorageService.instance.saveBusinessData(_business!.toJson());
    } catch (e) {
      debugPrint('Error updating business: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getNextInvoiceNumber() {
    final prefix = _business?.invoicePrefix ?? 'RE';
    final counter = _business?.invoiceCounter ?? 0;
    return '$prefix-${counter.toString().padLeft(4, '0')}';
  }

  Future<String> generateAndIncrementInvoiceNumber() async {
    final invoiceNumber = getNextInvoiceNumber();

    // Auto-increment the counter for next invoice
    if (_business != null) {
      final updatedBusiness = _business!.copyWith(
        invoiceCounter: (_business!.invoiceCounter == 0
            ? 1
            : _business!.invoiceCounter + 1),
      );
      await updateBusiness(updatedBusiness);
    }

    return invoiceNumber;
  }

  Future<void> incrementInvoiceCounter() async {
    if (_business != null) {
      final updatedBusiness = _business!.copyWith(
        invoiceCounter: _business!.invoiceCounter + 1,
      );
      await updateBusiness(updatedBusiness);
    }
  }

  Future<void> clearBusinessData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await StorageService.instance.clearBusinessData();
      _business = null;
    } catch (e) {
      debugPrint('Error clearing business data: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
