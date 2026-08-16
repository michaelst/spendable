import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';

part 'transactions_providers.g.dart';

const _perPage = 50;

/// The list is a queue of what still needs attention, so excluded rows are hidden by default.
/// Reviewed ones are shown, which the API does not assume - it has to be asked for.
class TransactionFilters {
  const TransactionFilters({this.search, this.showReviewed = true, this.showExcluded = false});

  final String? search;
  final bool showReviewed;
  final bool showExcluded;

  TransactionFilters copyWith({String? search, bool? showReviewed, bool? showExcluded}) => TransactionFilters(
    search: search ?? this.search,
    showReviewed: showReviewed ?? this.showReviewed,
    showExcluded: showExcluded ?? this.showExcluded,
  );

  /// Mirrors `visible?/2`: a row leaves the list when a change no longer matches, which is what
  /// makes reviewing clear the queue.
  bool matches(Transaction transaction) =>
      (showReviewed || !transaction.reviewed) && (showExcluded || !transaction.excluded);
}

@riverpod
class Filters extends _$Filters {
  @override
  TransactionFilters build() => const TransactionFilters();

  void search(String term) => state = state.copyWith(search: term.isEmpty ? null : term);

  void toggleReviewed() => state = state.copyWith(showReviewed: !state.showReviewed);

  void toggleExcluded() => state = state.copyWith(showExcluded: !state.showExcluded);
}

class TransactionPage {
  const TransactionPage({required this.transactions, required this.atEnd});

  final List<Transaction> transactions;
  final bool atEnd;
}

/// Pages append rather than replace. A page shorter than what was asked for is the last one.
@riverpod
class Transactions extends _$Transactions {
  var _page = 1;

  /// Watching the filters is what refetches when one changes, and is also what keeps them from
  /// being disposed while the sheet that edits them is closed.
  @override
  Future<TransactionPage> build() async {
    final filters = ref.watch(filtersProvider);

    _page = 1;

    return TransactionPage(transactions: await _fetch(1, filters), atEnd: false);
  }

  Future<void> loadMore() async {
    final current = state.value;

    if (current == null || current.atEnd || state.isLoading) return;

    final next = await _fetch(_page + 1, ref.read(filtersProvider));

    _page += 1;

    state = AsyncData(
      TransactionPage(transactions: [...current.transactions, ...next], atEnd: next.length < _perPage),
    );
  }

  /// Replaces one row with what the server settled on, or drops it when it no longer belongs in
  /// the list. Rewriting the row keeps the reader's place; refetching would send them to the top.
  void replace(Transaction transaction) {
    final current = state.value;

    if (current == null) return;

    final matches = ref.read(filtersProvider).matches(transaction);

    state = AsyncData(
      TransactionPage(
        transactions: [
          for (final existing in current.transactions)
            if (existing.id != transaction.id) existing else if (matches) transaction,
        ],
        atEnd: current.atEnd,
      ),
    );
  }

  void remove(Iterable<String> ids) {
    final current = state.value;

    if (current == null) return;

    state = AsyncData(
      TransactionPage(
        transactions: current.transactions.where((each) => !ids.contains(each.id)).toList(),
        atEnd: current.atEnd,
      ),
    );
  }

  Future<List<Transaction>> _fetch(int page, TransactionFilters filters) async {
    final response = await ref
        .read(apiProvider)
        .getTransactionsApi()
        .listTransactions(
          search: filters.search,
          page: page,
          perPage: _perPage,
          showReviewed: filters.showReviewed,
          showExcluded: filters.showExcluded,
        )
        .orApiError();

    return response.data!.toList();
  }
}

/// The budget and split pickers the rows and the detail sheet offer.
@riverpod
Future<List<Budget>> budgetOptions(Ref ref) async {
  final response = await ref.watch(apiProvider).getBudgetsApi().listBudgets().orApiError();

  return response.data!.toList();
}

@riverpod
Future<List<Split>> splitOptions(Ref ref) async {
  final response = await ref.watch(apiProvider).getSplitsApi().listSplits().orApiError();

  return response.data!.toList();
}

@riverpod
class Selection extends _$Selection {
  @override
  Set<String> build() => const {};

  void toggle(String id) => state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};

  void clear() => state = const {};
}
