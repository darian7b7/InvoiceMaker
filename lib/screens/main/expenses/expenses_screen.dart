import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../models/expense.dart';
import '../../../providers/expense_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/format.dart';
import '../main_actions.dart';
import 'expense_dialog.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>().expenses;

    if (expenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_cart_outlined,
                  size: 64, color: AppTheme.textTertiaryColor),
              const SizedBox(height: AppTheme.spacingM),
              Text('no_expenses_yet'.tr,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'no_expenses_hint'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondaryColor),
              ),
              const SizedBox(height: AppTheme.spacingL),
              ElevatedButton.icon(
                onPressed: () => openAddExpense(context),
                icon: const Icon(Icons.add),
                label: Text('new_expense'.tr),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingM,
        AppTheme.spacingM,
        AppTheme.spacingM,
        88,
      ),
      itemCount: expenses.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spacingS),
      itemBuilder: (context, index) => _ExpenseTile(expense: expenses[index]),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;

  const _ExpenseTile({required this.expense});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_expense'.tr),
        content: Text(expense.description),
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
    if (confirmed == true && context.mounted) {
      await context.read<ExpenseProvider>().deleteExpense(expense.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => showDialog(
          context: context,
          builder: (_) => ExpenseDialog(expense: expense),
        ),
        leading: const CircleAvatar(
          backgroundColor: Color(0x1AF97316),
          child:
              Icon(Icons.shopping_cart, color: AppTheme.warningColor, size: 20),
        ),
        title: Text(expense.description,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
            '${formatDate(expense.date)} · ${'expense_${expense.category.name}'.tr}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(formatEuro(expense.amount),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'delete'.tr,
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }
}
