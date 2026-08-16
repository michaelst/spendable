import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendable/budgets/budget_card.dart';
import 'package:spendable/money.dart';
import 'package:spendable_api/spendable_api.dart';

/// The same table `lib/spendable_web/utils/budget_card_test.exs` runs, so a change to either
/// side that the other did not follow fails here.
final _fixtures = jsonDecode(File('../shared/budget_cards.json').readAsStringSync()) as Map<String, dynamic>;

const _bars = {'under': CardBar.under, 'over': CardBar.over, 'goal': CardBar.goal};

void main() {
  for (final entry in _fixtures['cards'] as List) {
    final fixture = entry as Map<String, dynamic>;
    final expected = fixture['card'] as Map<String, dynamic>;
    final source = fixture['budget'] as Map<String, dynamic>;

    test(fixture['name'] as String, () {
      final budget = Budget(
        (builder) => builder
          ..id = 'bgt_fixture'
          ..name = 'Fixture'
          ..type = BudgetTypeEnum.valueOf(source['type'] as String)
          ..balance = source['balance'] as String
          ..budgetedAmount = source['budgeted_amount'] as String?,
      );

      final card = BudgetCard.build(
        budget: budget,
        spent: money(fixture['spent'] as String),
        currentMonth: fixture['current_month'] as bool,
      );

      expect(card.label, expected['label']);
      expect(card.percent, expected['percent']);
      expect(card.bar, _bars[expected['bar']]);
      expect(card.footer, expected['footer']);
      expect(card.amount, money(expected['amount'] as String));
    });
  }

  for (final entry in _fixtures['currency'] as List) {
    final fixture = entry as Map<String, dynamic>;
    final amount = fixture['amount'] as String?;

    test('formats ${amount ?? 'nothing'} as ${fixture['formatted']}', () {
      expect(formatCurrency(amount == null ? null : Decimal.parse(amount)), fixture['formatted']);
    });
  }
}
