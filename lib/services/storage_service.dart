import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores business, clients and invoices as JSON in SharedPreferences.
/// Works on every platform, including web (backed by localStorage).
class StorageService {
  static final StorageService _instance = StorageService._internal();
  static StorageService get instance => _instance;

  StorageService._internal();

  static const _businessKey = 'db_business';
  static const _clientsKey = 'db_clients';
  static const _invoicesKey = 'db_invoices';
  static const _expensesKey = 'db_expenses';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<Map<String, dynamic>> _readList(String key) {
    final raw = _prefs!.getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  Future<void> _writeList(String key, List<Map<String, dynamic>> items) async {
    await _prefs!.setString(key, jsonEncode(items));
  }

  // Business data methods
  Future<void> saveBusinessData(Map<String, dynamic> businessData) async {
    await _prefs!.setString(_businessKey, jsonEncode(businessData));
  }

  Future<Map<String, dynamic>?> getBusinessData() async {
    return getBusinessDataSync();
  }

  Future<void> clearBusinessData() async {
    await _prefs!.remove(_businessKey);
  }

  // Client data methods
  Future<void> saveClients(List<Map<String, dynamic>> clientsData) async {
    await _writeList(_clientsKey, clientsData);
  }

  Future<List<Map<String, dynamic>>> getClients() async {
    return _readList(_clientsKey);
  }

  // Invoice data methods
  Future<void> saveInvoices(List<Map<String, dynamic>> invoicesData) async {
    await _writeList(_invoicesKey, invoicesData);
  }

  Future<List<Map<String, dynamic>>> getInvoices() async {
    return _readList(_invoicesKey);
  }

  // Expense data methods
  Future<void> saveExpenses(List<Map<String, dynamic>> expensesData) async {
    await _writeList(_expensesKey, expensesData);
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    return _readList(_expensesKey);
  }

  // Backup: every stored record as one JSON document, and restoring it.
  String exportAll() {
    return jsonEncode({
      'app': 'invoice_maker',
      'version': 1,
      'business': getBusinessDataSync(),
      'clients': _readList(_clientsKey),
      'invoices': _readList(_invoicesKey),
      'expenses': _readList(_expensesKey),
    });
  }

  /// Throws [FormatException] if [json] is not a backup made by [exportAll].
  Future<void> importAll(String json) async {
    final data = jsonDecode(json);
    if (data is! Map<String, dynamic> || data['app'] != 'invoice_maker') {
      throw const FormatException('Not an Invoice Maker backup');
    }
    final business = data['business'] as Map<String, dynamic>?;
    if (business == null) {
      await clearBusinessData();
    } else {
      await saveBusinessData(business);
    }
    await _writeList(_clientsKey, _listOf(data['clients']));
    await _writeList(_invoicesKey, _listOf(data['invoices']));
    await _writeList(_expensesKey, _listOf(data['expenses']));
  }

  List<Map<String, dynamic>> _listOf(dynamic value) =>
      (value as List? ?? []).cast<Map<String, dynamic>>();

  Map<String, dynamic>? getBusinessDataSync() {
    final raw = _prefs!.getString(_businessKey);
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getInvoicesByStatus(String status) async {
    return (await getInvoices()).where((i) => i['status'] == status).toList();
  }

  Future<List<Map<String, dynamic>>> getInvoicesByClient(
      String clientId) async {
    return (await getInvoices())
        .where((i) => i['clientId'] == clientId)
        .toList();
  }

  // Search methods
  Future<List<Map<String, dynamic>>> searchInvoices(String query) async {
    final q = query.toLowerCase();
    return (await getInvoices())
        .where((i) => jsonEncode(i).toLowerCase().contains(q))
        .toList();
  }

  Future<List<Map<String, dynamic>>> searchClients(String query) async {
    final q = query.toLowerCase();
    return (await getClients())
        .where((c) => jsonEncode(c).toLowerCase().contains(q))
        .toList();
  }

  // Statistics methods
  Future<Map<String, dynamic>> getInvoiceStatistics() async {
    final invoices = await getInvoices();
    double sumWhere(String status) => invoices
        .where((i) => i['status'] == status)
        .fold(0.0, (sum, i) => sum + ((i['total'] as num?)?.toDouble() ?? 0));

    return {
      'totalInvoices': invoices.length,
      'paidInvoices': invoices.where((i) => i['status'] == 'paid').length,
      'totalRevenue': sumWhere('paid'),
      'pendingAmount': sumWhere('sent'),
    };
  }

  // Cache management
  Future<void> clearAllData() async {
    await _prefs?.clear();
  }

  Future<int> getDatabaseSize() async {
    final business = _prefs!.containsKey(_businessKey) ? 1 : 0;
    return business +
        _readList(_clientsKey).length +
        _readList(_invoicesKey).length;
  }
}
