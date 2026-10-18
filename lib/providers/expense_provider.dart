import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];

  /// Newest first.
  List<Expense> get expenses => _expenses;

  Future<void> loadExpenses() async {
    final data = await StorageService.instance.getExpenses();
    _expenses = data.map(Expense.fromJson).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> saveExpense(Expense expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index == -1) {
      _expenses.add(expense);
    } else {
      _expenses[index] = expense;
    }
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    await _save();
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await _save();
  }

  List<Expense> expensesInYear(int year) =>
      _expenses.where((e) => e.date.year == year).toList();

  Future<void> _save() async {
    await StorageService.instance
        .saveExpenses(_expenses.map((e) => e.toJson()).toList());
    notifyListeners();
  }
}
