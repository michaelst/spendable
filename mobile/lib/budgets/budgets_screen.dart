import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendable_api/spendable_api.dart';

import '../auth/account_screen.dart';
import '../money.dart';
import '../theme.dart';
import 'budget_card.dart';
import 'budget_form.dart';
import 'budgets_providers.dart';

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String monthName(Date month) => '${_months[month.month - 1]} ${month.year}';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(budgetSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: switch (summary) {
          AsyncData(value: final summary) => _MonthPicker(summary: summary),
          _ => const Text('Budgets'),
        },
        actions: [
          IconButton(
            key: const Key('open-account'),
            icon: const Icon(Icons.person_outline),
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AccountScreen())),
          ),
          IconButton(
            key: const Key('new-budget'),
            icon: const Icon(Icons.add),
            onPressed: () => openBudgetForm(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(budgetSummaryProvider),
        child: switch (summary) {
          AsyncData(value: final summary) => _Budgets(summary: summary),
          AsyncError(:final error) => _Retry(message: '$error'),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

Future<void> openBudgetForm(BuildContext context, {Budget? budget}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => BudgetForm(budget: budget),
);

class _MonthPicker extends ConsumerWidget {
  const _MonthPicker({required this.summary});

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<Date>(
      key: const Key('month-picker'),
      onSelected: (month) => ref.read(selectedMonthProvider.notifier).select(month),
      itemBuilder: (_) => [
        for (final entry in summary.spentByMonth)
          PopupMenuItem(
            value: entry.month,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(monthName(entry.month)),
                Text(
                  'spent: ${formatCurrency(money(entry.spent))}',
                  style: const TextStyle(color: SpendableColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(monthName(summary.month), style: Theme.of(context).textTheme.titleLarge),
          const Icon(Icons.unfold_more, size: 18, color: SpendableColors.muted),
        ],
      ),
    );
  }
}

class _Budgets extends StatelessWidget {
  const _Budgets({required this.summary});

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final budgets = listedBudgets(summary);

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: budgets.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == 0) return _Totals(summary: summary);

        final budget = budgets[index - 1];

        return _Card(
          budget: budget,
          spent: money(summary.spent[budget.id] ?? '0').abs(),
          currentMonth: summary.currentMonth,
        );
      },
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.summary});

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final spendable = money(summary.spendable);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (summary.currentMonth)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Caption('Spendable'),
                  Text(
                    formatCurrency(spendable),
                    key: const Key('spendable-total'),
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                      color: spendable.sign < 0 ? SpendableColors.negative : SpendableColors.positive,
                    ),
                  ),
                ],
              ),
            ),
          if (summary.currentMonth) _Total(label: 'Allocated', amount: money(summary.allocatedTotal)),
          const SizedBox(width: 24),
          _Total(label: 'Spent', amount: money(summary.spentTotal)),
        ],
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.label, required this.amount});

  final String label;
  final Decimal amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(formatCurrency(amount), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        _Caption(label),
      ],
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(color: SpendableColors.muted, fontSize: 11, letterSpacing: 0.8),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.budget, required this.spent, required this.currentMonth});

  static const _barColors = {
    CardBar.under: SpendableColors.accent,
    CardBar.over: SpendableColors.negative,
    CardBar.goal: SpendableColors.positive,
  };

  final Budget budget;
  final Decimal spent;
  final bool currentMonth;

  @override
  Widget build(BuildContext context) {
    final card = BudgetCard.build(budget: budget, spent: spent, currentMonth: currentMonth);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: SpendableColors.surface,
      child: InkWell(
        // The credit card total is a reading of the bank accounts, not a row anyone can edit.
        onTap: budget.id == creditCardsId ? null : () => openBudgetForm(context, budget: budget),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      budget.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  _Pill(type: budget.type),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    formatCurrency(card.amount),
                    key: Key('amount-${budget.id}'),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: card.amount.sign < 0 ? SpendableColors.negative : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Caption(card.label),
                ],
              ),
              if (card.percent case final percent?) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    key: Key('bar-${budget.id}'),
                    value: percent / 100,
                    minHeight: 4,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation(_barColors[card.bar]),
                  ),
                ),
              ],
              if (card.footer case final footer?) ...[
                const SizedBox(height: 10),
                Text(footer, style: const TextStyle(color: SpendableColors.muted, fontSize: 12)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.type});

  static const _labels = {
    BudgetTypeEnum.envelope: ('Envelope', SpendableColors.accent),
    BudgetTypeEnum.goal: ('Goal', SpendableColors.positive),
    BudgetTypeEnum.tracking: ('Tracking', SpendableColors.muted),
  };

  final BudgetTypeEnum type;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _labels[type] ?? ('Envelope', SpendableColors.accent);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _Retry extends ConsumerWidget {
  const _Retry({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(budgetSummaryProvider),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
