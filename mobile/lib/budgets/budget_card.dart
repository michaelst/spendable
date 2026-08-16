import 'package:decimal/decimal.dart';
import 'package:spendable_api/spendable_api.dart';

import '../money.dart';

/// Which of the three bars a card draws. Colours are the screen's business.
enum CardBar { under, over, goal }

/// What a budget reads as, mirroring `SpendableWeb.Utils.BudgetCard`. Both are driven by
/// shared/budget_cards.json, which is the only thing keeping them from drifting apart.
class BudgetCard {
  const BudgetCard({required this.amount, required this.label, this.percent, this.bar, this.footer});

  factory BudgetCard.build({required Budget budget, required Decimal spent, required bool currentMonth}) {
    // A past month is a record of what was spent, so a balance read now says nothing about it.
    if (!currentMonth) return BudgetCard(amount: spent, label: 'SPENT');

    if (budget.type == BudgetTypeEnum.tracking) {
      return BudgetCard(amount: spent, label: 'SPENT', footer: 'No limit set');
    }

    final goal = budget.type == BudgetTypeEnum.goal;
    final balance = money(budget.balance);
    final budgeted = budget.budgetedAmount == null ? null : money(budget.budgetedAmount!);

    if (budgeted == null) {
      return goal
          ? BudgetCard(amount: balance, label: 'SAVED', footer: 'No goal set')
          : BudgetCard(amount: balance, label: 'LEFT', footer: 'No limit set');
    }

    if (goal) {
      return BudgetCard(
        amount: budgeted - balance,
        label: 'TO GO',
        percent: _percent(balance, budgeted),
        bar: CardBar.goal,
        footer: '${formatCurrency(balance)} of ${formatCurrency(budgeted)} saved',
      );
    }

    return BudgetCard(
      amount: balance,
      label: 'LEFT',
      percent: _percent(spent, budgeted),
      bar: spent > budgeted ? CardBar.over : CardBar.under,
      footer: '${formatCurrency(spent)} of ${formatCurrency(budgeted)} spent',
    );
  }

  final Decimal amount;
  final String label;
  final double? percent;
  final CardBar? bar;
  final String? footer;

  static double _percent(Decimal part, Decimal whole) {
    if (whole == Decimal.zero) return 0;

    final value = (part / whole).toDecimal(scaleOnInfinitePrecision: 28).toDouble() * 100;

    return double.parse(value.clamp(0, 100).toStringAsFixed(1));
  }
}
