import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';
import '../money.dart';

part 'budgets_providers.g.dart';

/// The id given to the synthetic Credit Cards card, which is not a budget and has no row.
const creditCardsId = 'credit-cards';

/// Where unallocated money lands. The server names it and sorts it first; neither it nor the
/// credit card total is a row anyone edits.
const spendableName = 'Spendable';

bool isEditable(Budget budget) => budget.id != creditCardsId && budget.name != spendableName;

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
  if (summary.budgets.isEmpty) return const [];

  final spendable = summary.budgets.where((budget) => budget.name == spendableName).firstOrNull;

  // Envelopes, then goals, then what is only tracked, alphabetical inside each. Grouping them by
  // what they are does the work a heading over each group would, without the headings.
  final rest = summary.budgets.where((budget) => budget.id != spendable?.id).toList()
    ..sort((a, b) {
      final byType = _typeOrder(a.type).compareTo(_typeOrder(b.type));

      return byType == 0 ? a.name.compareTo(b.name) : byType;
    });

  // A past month has no Spendable figure over the list, so the budget is the only place to read
  // what came out of it.
  if (!summary.currentMonth) return [?spendable, ...rest];

  final creditCards = Budget(
    (builder) => builder
      ..id = creditCardsId
      ..name = 'Credit Cards'
      ..type = BudgetTypeEnum.envelope
      ..balance = (-money(summary.creditCardBalance)).toString(),
  );

  // Spendable is the figure the screen opens with, so listing it again underneath only says the
  // same word twice about two different numbers. The card total takes the first row instead.
  return [creditCards, ...rest];
}

int _typeOrder(BudgetTypeEnum type) => switch (type) {
  BudgetTypeEnum.envelope => 0,
  BudgetTypeEnum.goal => 1,
  _ => 2,
};

/// The budget picker every other screen offers.
@riverpod
Future<List<Budget>> budgetOptions(Ref ref) async {
  final response = await ref.watch(apiProvider).getBudgetsApi().listBudgets().orApiError();

  return response.data!.toList();
}
