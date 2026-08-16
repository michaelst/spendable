import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendable_api/spendable_api.dart';

import '../design/glass_sheet.dart';
import '../design/ledger_row.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import 'budgets_providers.dart';

/// The one way a budget gets chosen, wherever the choosing happens.
Future<Budget?> pickBudget(BuildContext context, WidgetRef ref) {
  final budgets = ref.read(budgetOptionsProvider).value ?? const <Budget>[];

  return showGlassSheet<Budget>(
    context,
    (context) => ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      children: [
        for (final budget in budgets)
          LedgerRow(
            key: Key('budget-${budget.id}'),
            onTap: () => Navigator.of(context).pop(budget),
            child: Text(
              budget.name,
              style: SpendableType.title.copyWith(color: SpendableColors.of(context).primary),
            ),
          ),
      ],
    ),
  );
}
