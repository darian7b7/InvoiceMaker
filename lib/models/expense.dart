/// A business purchase (Ausgabe), e.g. material, goods for resale or tools.
/// [amount] is the gross amount paid (brutto), as printed on the receipt.
class Expense {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final double vatRate;
  final ExpenseCategory category;

  Expense({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.vatRate,
    required this.category,
  });

  /// Vorsteuer contained in the gross amount.
  double get vatAmount => amount - netAmount;
  double get netAmount => amount / (1 + vatRate / 100);

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'description': description,
        'amount': amount,
        'vatRate': vatRate,
        'category': category.name,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'],
        date: DateTime.parse(json['date']),
        description: json['description'],
        amount: (json['amount'] as num).toDouble(),
        vatRate: (json['vatRate'] as num).toDouble(),
        category: ExpenseCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => ExpenseCategory.other,
        ),
      );
}

enum ExpenseCategory { material, goods, tools, vehicle, office, other }
