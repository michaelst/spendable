import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';
import 'budgets_providers.dart';

part 'budgets_controller.g.dart';

/// Writing budgets. Every write re-reads the summary rather than patching the list: changing one
/// budget's allocation moves what is left on Spendable, so the row that came back is not the only
/// one that changed.
@riverpod
class BudgetsController extends _$BudgetsController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> save({String? id, required BudgetRequest request}) => _run(() async {
    final budgets = ref.read(apiProvider).getBudgetsApi();

    if (id == null) {
      await budgets.createBudget(budgetRequest: request).orApiError();
    } else {
      await budgets.updateBudget(id: id, budgetRequest: request).orApiError();
    }
  });

  /// Budgets are archived rather than deleted, so the history they hold survives.
  Future<bool> archive(String id) =>
      _run(() => ref.read(apiProvider).getBudgetsApi().archiveBudget(id: id).orApiError());

  Future<bool> _run(Future<void> Function() write) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(write);

    if (state.hasError) return false;

    ref.invalidate(budgetSummaryProvider);

    return true;
  }
}
