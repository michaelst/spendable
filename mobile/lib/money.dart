import 'package:decimal/decimal.dart';

/// Amounts cross the wire as decimal strings, so they stay exact rather than becoming doubles.
Decimal money(String value) => Decimal.parse(value);

/// Mirrors `Spendable.Utils.format_currency/1`, which the web app renders with. Kept in step by
/// shared/budget_cards.json.
String formatCurrency(Decimal? amount) {
  if (amount == null) return r'$0.00';

  final text = amount.abs().round(scale: 2).toStringAsFixed(2);
  final dot = text.lastIndexOf('.');
  final sign = amount.sign < 0 ? r'-$' : r'$';

  return '$sign${_grouped(text.substring(0, dot))}${text.substring(dot)}';
}

String _grouped(String dollars) {
  final digits = dollars.split('').reversed.toList();
  final chunks = <String>[];

  for (var start = 0; start < digits.length; start += 3) {
    final end = start + 3 < digits.length ? start + 3 : digits.length;

    chunks.add(digits.sublist(start, end).join());
  }

  return chunks.join(',').split('').reversed.join();
}
