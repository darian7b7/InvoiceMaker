import 'package:intl/intl.dart';

final _euro = NumberFormat.currency(locale: 'de_DE', symbol: '€');
final _euroPdf = NumberFormat.currency(locale: 'de_DE', symbol: 'EUR');

/// German money format, e.g. 1.234,50 €
String formatEuro(double amount) => _euro.format(amount);

/// Same as [formatEuro] but with "EUR": the PDF's built-in font has no € glyph.
String formatEuroPdf(double amount) => _euroPdf.format(amount);

/// Rounds to whole cents, as amounts on an invoice must be.
double roundCents(double amount) => (amount * 100).round() / 100;

/// German date format, e.g. 13.10.2026
String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

/// Accepts both "12,50" and "12.50" (and "1.234,50").
double? parseAmount(String input) {
  var text = input.trim().replaceAll('€', '').replaceAll(' ', '');
  if (text.contains(',')) {
    text = text.replaceAll('.', '').replaceAll(',', '.');
  }
  return double.tryParse(text);
}

/// VAT rates that can be used in Germany.
const vatRates = [19.0, 7.0, 0.0];

/// Invoice item units: stored code → label printed on the invoice.
const invoiceUnits = {
  'no_unit': '',
  'hours': 'Std.',
  'pieces': 'Stk.',
  'pauschal': 'pauschal',
  'm2': 'm²',
  'm': 'm',
  'kg': 'kg',
};

/// Older builds stored some units under different codes.
String unitCode(String code) =>
    const {'kilograms': 'kg', 'square_meters': 'm2'}[code] ??
    (invoiceUnits.containsKey(code) ? code : 'no_unit');

/// 2.0 → "2", 2.5 → "2,5"
String formatQuantity(double quantity) => (quantity == quantity.roundToDouble()
        ? quantity.toStringAsFixed(0)
        : quantity.toString())
    .replaceAll('.', ',');
