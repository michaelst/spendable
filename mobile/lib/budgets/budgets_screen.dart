import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendable_api/spendable_api.dart';

import '../auth/account_screen.dart';
import '../design/band_button.dart';
import '../design/caption.dart';
import '../design/glass_menu.dart';
import '../design/glass_sheet.dart';
import '../design/glyph_icon.dart';
import '../design/ledger_row.dart';
import '../design/ledger_screen.dart';
import '../design/money_text.dart';
import '../design/nav_band.dart';
import '../design/section_rule.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import '../money.dart';
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

    return LedgerScreen(
      onRefresh: () async => ref.invalidate(budgetSummaryProvider),
      band: NavBand(
        title: switch (summary) {
          AsyncData(value: final summary) => monthName(summary.month),
          _ => 'Budgets',
        },
        largeTitle: switch (summary) {
          AsyncData(value: final summary) => _MonthPicker(summary: summary),
          _ => null,
        },
        actions: [
          BandButton(
            key: const Key('open-account'),
            icon: Glyph.user,
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AccountScreen())),
          ),
          BandButton(
            key: const Key('new-budget'),
            icon: Glyph.plus,
            onPressed: () => openBudgetForm(context),
          ),
        ],
      ),
      slivers: switch (summary) {
        AsyncData(value: final summary) => _budgets(summary),
        AsyncError(:final error) => [_Retry(message: '$error')],
        _ => const [
          SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator())),
        ],
      },
    );
  }

  List<Widget> _budgets(BudgetSummary summary) {
    final listed = listedBudgets(summary);
    final owned = listed.where((budget) => budget.id != creditCardsId).toList();
    final creditCards = listed.where((budget) => budget.id == creditCardsId).firstOrNull;

    return [
      SliverToBoxAdapter(child: _Totals(summary: summary)),
      SliverList.builder(
        itemCount: owned.length,
        itemBuilder: (_, index) => _Row(budget: owned[index], summary: summary),
      ),
      // Card debt is read off the connected accounts rather than allocated, so it is set apart from
      // the budgets the user keeps.
      if (creditCards case final creditCards?) ...[
        const SliverToBoxAdapter(child: SectionRule('From connected accounts')),
        SliverToBoxAdapter(
          child: _Row(budget: creditCards, summary: summary),
        ),
      ],
    ];
  }
}

Future<void> openBudgetForm(BuildContext context, {Budget? budget}) =>
    showGlassSheet<void>(context, (_) => BudgetForm(budget: budget));

class _MonthPicker extends ConsumerWidget {
  const _MonthPicker({required this.summary});

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SpendableColors.of(context);

    return GestureDetector(
      key: const Key('month-picker'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _pick(context, ref),
      // A long month at a large size runs past a narrow phone, and the title is worth more whole
      // and a little smaller than it is truncated.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(monthName(summary.month), style: SpendableType.largeTitle.copyWith(color: colors.primary)),
            const SizedBox(width: SpendableSpace.tight),
            GlyphIcon(Glyph.caretDown, size: 17, color: colors.tertiary),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final chosen = await showGlassMenu<Date>(context, [
      for (final entry in summary.spentByMonth)
        GlassMenuItem(
          value: entry.month,
          title: monthName(entry.month),
          subtitle: 'spent: ${formatCurrency(money(entry.spent).abs())}',
          selected: entry.month == summary.month,
        ),
    ]);

    if (chosen != null) ref.read(selectedMonthProvider.notifier).select(chosen);
  }
}

/// The answer the app exists to give, and the two figures it is worked out from.
class _Totals extends StatelessWidget {
  const _Totals({required this.summary});

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpendableSpace.gutter,
        SpendableSpace.tight,
        SpendableSpace.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (summary.currentMonth)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Caption('Spendable'),
                      MoneyText(
                        money(summary.spendable),
                        key: const Key('spendable-total'),
                        style: SpendableType.moneyHero,
                        creditIsPositive: true,
                      ),
                    ],
                  ),
                ),
              if (summary.currentMonth) ...[
                _Total(label: 'Allocated', amount: money(summary.allocatedTotal)),
                const SizedBox(width: SpendableSpace.gutter),
              ],
              _Total(label: 'Spent', amount: money(summary.spentTotal)),
            ],
          ),
          const SizedBox(height: SpendableSpace.step),
          Container(height: 1, color: colors.separator),
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
        Caption(label),
        const SizedBox(height: 1),
        MoneyText(amount, style: SpendableType.moneyInline),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.budget, required this.summary});

  final Budget budget;
  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);

    final card = BudgetCard.build(
      budget: budget,
      spent: money(summary.spent[budget.id] ?? '0').abs(),
      currentMonth: summary.currentMonth,
    );

    final barColors = {
      CardBar.under: colors.accent,
      CardBar.over: colors.negative,
      CardBar.goal: colors.positive,
    };

    return LedgerRow(
      // The credit card total is a reading of the bank accounts, not a row anyone can edit.
      onTap: budget.id == creditCardsId ? null : () => openBudgetForm(context, budget: budget),
      ruleInset: 0,
      progress: card.percent == null ? null : card.percent! / 100,
      progressColor: barColors[card.bar],
      padding: const EdgeInsets.fromLTRB(
        SpendableSpace.gutter,
        SpendableSpace.step,
        SpendableSpace.gutter,
        SpendableSpace.step,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        budget.name,
                        overflow: TextOverflow.ellipsis,
                        style: SpendableType.title.copyWith(color: colors.primary),
                      ),
                    ),
                    const SizedBox(width: SpendableSpace.tight),
                    _Kind(type: budget.type),
                  ],
                ),
              ),
              MoneyText(card.amount, key: Key('amount-${budget.id}'), style: SpendableType.moneyRow),
              const SizedBox(width: SpendableSpace.hair),
              Caption(card.label),
            ],
          ),
          if (card.footer case final footer?) ...[
            const SizedBox(height: 1),
            Text(footer, style: SpendableType.subhead.copyWith(color: colors.secondary)),
          ],
        ],
      ),
    );
  }
}

/// The budget's kind, said in the margin next to its name rather than badged.
class _Kind extends StatelessWidget {
  const _Kind({required this.type});

  static const _labels = {
    BudgetTypeEnum.envelope: 'Envelope',
    BudgetTypeEnum.goal: 'Goal',
    BudgetTypeEnum.tracking: 'Tracking',
  };

  final BudgetTypeEnum type;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);

    final color = switch (type) {
      BudgetTypeEnum.goal => colors.positive,
      BudgetTypeEnum.tracking => colors.trackingPill,
      _ => colors.accent,
    };

    return Caption(_labels[type] ?? 'Envelope', color: color);
  }
}

class _Retry extends ConsumerWidget {
  const _Retry({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SpendableColors.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(SpendableSpace.block),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: SpendableType.body.copyWith(color: colors.secondary),
            ),
            const SizedBox(height: SpendableSpace.gutter),
            BandButton(label: 'Try again', onPressed: () => ref.invalidate(budgetSummaryProvider)),
          ],
        ),
      ),
    );
  }
}
