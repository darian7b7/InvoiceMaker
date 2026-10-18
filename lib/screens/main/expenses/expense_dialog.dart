import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../models/expense.dart';
import '../../../providers/expense_provider.dart';
import '../../../utils/format.dart';

/// Add a new expense, or edit [expense] when given.
class ExpenseDialog extends StatefulWidget {
  final Expense? expense;

  const ExpenseDialog({super.key, this.expense});

  @override
  State<ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<ExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late DateTime _date;
  late double _vatRate;
  late ExpenseCategory _category;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _descriptionController =
        TextEditingController(text: expense?.description ?? '');
    _amountController = TextEditingController(
      text: expense == null
          ? ''
          : expense.amount.toStringAsFixed(2).replaceAll('.', ','),
    );
    _date = expense?.date ?? DateTime.now();
    _vatRate = expense?.vatRate ?? 19;
    _category = expense?.category ?? ExpenseCategory.material;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<ExpenseProvider>().saveExpense(Expense(
          id: widget.expense?.id ?? const Uuid().v4(),
          date: _date,
          description: _descriptionController.text.trim(),
          amount: parseAmount(_amountController.text)!,
          vatRate: _vatRate,
          category: _category,
        ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.expense == null ? 'new_expense'.tr : 'edit_expense'.tr),
      // Fixed width: AlertDialog otherwise shrinks to its content and clips labels.
      content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _descriptionController,
                    decoration:
                        InputDecoration(labelText: 'expense_description'.tr),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'required'.tr : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                        labelText: 'amount_gross'.tr, suffixText: '€'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final amount = parseAmount(v ?? '');
                      return amount == null || amount <= 0
                          ? 'enter_valid_amount'.tr
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<double>(
                    initialValue: _vatRate,
                    decoration: InputDecoration(labelText: 'vat_included'.tr),
                    items: vatRates
                        .map((rate) => DropdownMenuItem(
                            value: rate,
                            child: Text('${rate.toStringAsFixed(0)} %')))
                        .toList(),
                    onChanged: (value) => setState(() => _vatRate = value!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ExpenseCategory>(
                    initialValue: _category,
                    decoration: InputDecoration(labelText: 'category'.tr),
                    items: ExpenseCategory.values
                        .map((c) => DropdownMenuItem(
                            value: c, child: Text('expense_${c.name}'.tr)))
                        .toList(),
                    onChanged: (value) => setState(() => _category = value!),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: 'date'.tr),
                      child: Text(formatDate(_date)),
                    ),
                  ),
                ],
              ),
            ),
          )),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr)),
        ElevatedButton(onPressed: _save, child: Text('save'.tr)),
      ],
    );
  }
}
