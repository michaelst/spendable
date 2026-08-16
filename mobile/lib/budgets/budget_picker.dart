import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendable_api/spendable_api.dart';

import '../design/glass_sheet.dart';
import '../design/ledger_row.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import 'budgets_providers.dart';

/// The one way a budget gets chosen, wherever the choosing happens.
Future<Budget?> pickBudget(BuildContext context) =>
    showGlassSheet<Budget>(context, (_) => const _BudgetPicker());

/// The list is watched rather than read: a screen that never loaded it would otherwise open a
/// sheet with nothing in it, which on a sheet sized to its contents is a sheet that never appears.
class _BudgetPicker extends ConsumerWidget {
  const _BudgetPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetOptionsProvider);
    final colors = SpendableColors.of(context);

    return switch (budgets) {
      AsyncData(value: final budgets) when budgets.isEmpty => const _Message('No budgets yet.'),
      AsyncData(value: final budgets) => ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        children: [
          for (final budget in budgets)
            LedgerRow(
              key: Key('budget-${budget.id}'),
              onTap: () => Navigator.of(context).pop(budget),
              child: Text(budget.name, style: SpendableType.title.copyWith(color: colors.primary)),
            ),
        ],
      ),
      AsyncError(:final error) => _Message('$error'),
      _ => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
    };
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SpendableSpace.block),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: SpendableType.body.copyWith(color: SpendableColors.of(context).secondary),
      ),
    );
  }
}
