import 'package:decimal/decimal.dart';
import 'package:spendable_api/spendable_api.dart';

import '../money.dart';

/// Which of the four bars a card draws. Colours are the screen's business.
enum CardBar { under, over, goal, income }

/// What one month moved through a budget. Which figure a card reads depends on what kind of
/// budget it is, and a budget that spends never receives.
class BudgetMonth {
  const BudgetMonth({required this.spent, required this.received, required this.funded});

  final Decimal spent;
  final Decimal received;
  final Decimal funded;
}

/// What a budget reads as, mirroring `SpendableWeb.Utils.BudgetCard`. Both are driven by
/// shared/budget_cards.json, which is the only thing keeping them from drifting apart.
class BudgetCard {
  const BudgetCard({required this.amount, required this.label, this.percent, this.bar, this.footer});

  factory BudgetCard.build({
    required Budget budget,
    required BudgetMonth month,
    required bool currentMonth,
  }) {
    final income = budget.type == BudgetTypeEnum.income;
    final budgeted = budget.budgetedAmount == null ? null : money(budget.budgetedAmount!);
    final spent = month.spent;

    // A past month is a record of what moved, so a balance read now says nothing about it.
    if (!currentMonth) {
      return income
          ? BudgetCard(amount: month.received, label: 'EARNED')
          : BudgetCard(amount: spent, label: 'SPENT');
    }

    if (budget.type == BudgetTypeEnum.tracking) {
      if (budgeted == null) return BudgetCard(amount: spent, label: 'SPENT');

      return BudgetCard(
        amount: spent,
        label: 'SPENT',
        percent: _percent(spent, budgeted),
        bar: spent > budgeted ? CardBar.over : CardBar.under,
        footer: '${formatCurrency(spent)} of ${formatCurrency(budgeted)} spent',
      );
    }

    // Money in is the point here, so there is no bar to be the wrong side of: it fills as the
    // month earns and the footer says how far along that is.
    if (income) {
      final received = month.received;

      if (budgeted == null) return BudgetCard(amount: received, label: 'EARNED');

      return BudgetCard(
        amount: received,
        label: 'EARNED',
        percent: _percent(received, budgeted),
        bar: CardBar.income,
        footer: '${formatCurrency(received)} of ${formatCurrency(budgeted)} received',
      );
    }

    final goal = budget.type == BudgetTypeEnum.goal;
    final balance = money(budget.balance);
    final fundsItself = budget.fundingAmount == null ? null : money(budget.fundingAmount!);
    final funded = month.funded;

    if (budgeted == null) {
      if (goal) return BudgetCard(amount: balance, label: 'SAVED', footer: 'No goal set');

      final held = _held(balance);

      return BudgetCard(amount: held.amount, label: held.label, footer: _fundedFooter(funded));
    }

    if (goal) {
      final saved = '${formatCurrency(balance)} of ${formatCurrency(budgeted)} saved';

      return BudgetCard(
        amount: budgeted - balance,
        label: 'TO GO',
        percent: _percent(balance, budgeted),
        bar: CardBar.goal,
        footer: fundsItself == null ? saved : '$saved · ${formatCurrency(fundsItself)}/mo',
      );
    }

    final spend = '${formatCurrency(spent)} of ${formatCurrency(budgeted)} spent';
    final held = _held(balance);

    return BudgetCard(
      amount: held.amount,
      label: held.label,
      percent: _percent(spent, budgeted),
      bar: spent > budgeted ? CardBar.over : CardBar.under,
      footer: funded == Decimal.zero ? spend : '${formatCurrency(funded)} funded · $spend',
    );
  }

  final Decimal amount;
  final String label;
  final double? percent;
  final CardBar? bar;
  final String? footer;

  /// An envelope in the hole is not holding a negative amount, it is short by a positive one -
  /// the same way a goal counts what is still TO GO rather than a negative saving. The screen
  /// colours the label, since the figure no longer carries a minus sign to key off.
  static ({Decimal amount, String label}) _held(Decimal balance) => balance < Decimal.zero
      ? (amount: -balance, label: 'OVERSPENT')
      : (amount: balance, label: 'LEFT');

  /// What the month put in is only worth saying when a month put something in, so a budget the
  /// user fills by hand reads exactly as it did before funding existed.
  static String? _fundedFooter(Decimal funded) =>
      funded == Decimal.zero ? null : '${formatCurrency(funded)} funded';

  static double _percent(Decimal part, Decimal whole) {
    if (whole == Decimal.zero) return 0;

    final value = (part / whole).toDecimal(scaleOnInfinitePrecision: 28).toDouble() * 100;

    return double.parse(value.clamp(0, 100).toStringAsFixed(1));
  }
}
