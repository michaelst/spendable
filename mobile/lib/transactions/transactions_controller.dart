import 'package:built_collection/built_collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';
import 'transactions_providers.dart';

part 'transactions_controller.g.dart';

/// Writing transactions. Every write renders the transaction that came back rather than what was
/// sent: the server re-runs the allocation split on each save, so the response is the only
/// account of what a transaction now looks like.
@riverpod
class TransactionsController extends _$TransactionsController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> update(Transaction transaction, TransactionRequest request) => _write(() async {
    final response = await _api
        .updateTransaction(id: transaction.id, transactionRequest: request)
        .orApiError();

    ref.read(transactionsProvider.notifier).replace(response.data!);
  });

  Future<bool> toggleReviewed(Transaction transaction) =>
      update(transaction, TransactionRequest((builder) => builder.reviewed = !transaction.reviewed));

  Future<bool> bulk({required Set<String> ids, bool? reviewed, bool? excluded, String? budgetId}) =>
      _write(() async {
        final request = BulkRequest(
          (builder) => builder
            ..transactionIds = ListBuilder(ids)
            ..reviewed = reviewed
            ..excluded = excluded
            ..budgetId = budgetId,
        );

        final response = await _api.updateTransactions(bulkRequest: request).orApiError();

        _applyBulk(response.data!);
      });

  Future<bool> deleteAll(Set<String> ids) => _write(() async {
    final request = BulkRequest((builder) => builder.transactionIds = ListBuilder(ids));
    final response = await _api.deleteTransactions(bulkRequest: request).orApiError();

    ref.read(transactionsProvider.notifier).remove(ids.difference(_failedIds(response.data!)));
    ref.read(selectionProvider.notifier).clear();
  });

  /// Both sides of a transfer come back, because pairing changes them both.
  Future<bool> markAsTransfer(Set<String> ids) => _write(() async {
    final request = TransferRequest((builder) => builder.transactionIds = ListBuilder(ids));
    final response = await _api.createTransfer(transferRequest: request).orApiError();

    for (final transaction in response.data!) {
      ref.read(transactionsProvider.notifier).replace(transaction);
    }

    ref.read(selectionProvider.notifier).clear();
  });

  Future<bool> removeTransfer(Transaction transaction) => _write(() async {
    final response = await _api.deleteTransfer(id: transaction.id).orApiError();

    ref.read(transactionsProvider.notifier).replace(response.data!);
  });

  TransactionsApi get _api => ref.read(apiProvider).getTransactionsApi();

  void _applyBulk(BulkResult result) {
    for (final transaction in result.transactions) {
      ref.read(transactionsProvider.notifier).replace(transaction);
    }

    ref.read(selectionProvider.notifier).clear();
  }

  Set<String> _failedIds(BulkResult result) => result.failed.map((failure) => failure.id).toSet();

  Future<bool> _write(Future<void> Function() write) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(write);

    return !state.hasError;
  }
}
