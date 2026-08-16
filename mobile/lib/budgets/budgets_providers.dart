import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';
import '../money.dart';

part 'budgets_providers.g.dart';

/// The id given to the synthetic Credit Cards card, which is not a budget and has no row.
const creditCardsId = 'credit-cards';

/// Null leaves the choice to the server, which answers for the current month.
@riverpod
class SelectedMonth extends _$SelectedMonth {
  @override
  Date? build() => null;

  void select(Date month) => state = month;
}

@riverpod
class BudgetSearch extends _$BudgetSearch {
  @override
  String? build() => null;

  void set(String term) => state = term.isEmpty ? null : term;
}

@riverpod
Future<BudgetSummary> budgetSummary(Ref ref) async {
  final response = await ref
      .watch(apiProvider)
      .getBudgetsApi()
      .getBudgetSummary(month: ref.watch(selectedMonthProvider), search: ref.watch(budgetSearchProvider))
      .orApiError();

  return response.data!;
}

/// Card debt is not a budget, but it reads as one on this screen: a negative balance to cover.
/// It only makes sense against the current month, since it is what is owed right now.
List<Budget> listedBudgets(BudgetSummary summary) {
  if (!summary.currentMonth || summary.budgets.isEmpty) return summary.budgets.toList();

  final creditCards = Budget(
    (builder) => builder
      ..id = creditCardsId
      ..name = 'Credit Cards'
      ..type = BudgetTypeEnum.envelope
      ..balance = (-money(summary.creditCardBalance)).toString(),
  );

  // Spendable stays first; the card total sits beside it.
  return [summary.budgets.first, creditCards, ...summary.budgets.skip(1)];
}

/// The budget picker every other screen offers.
@riverpod
Future<List<Budget>> budgetOptions(Ref ref) async {
  final response = await ref.watch(apiProvider).getBudgetsApi().listBudgets().orApiError();

  return response.data!.toList();
}
