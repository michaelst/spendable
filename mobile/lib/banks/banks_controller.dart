import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';
import 'banks_providers.dart';
import 'plaid_link_flow.dart';

part 'banks_controller.g.dart';

/// Connecting banks and deciding what each account does.
@riverpod
class BanksController extends _$BanksController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// The bank limit is checked before Plaid is called, so a refusal comes back without the user
  /// having been sent through Link for nothing.
  Future<bool> connect() => _write(() async {
    final response = await _api.createLinkToken().orApiError();
    final publicToken = await ref.read(plaidLinkFlowProvider).open(response.data!.linkToken);

    if (publicToken == null) return;

    final request = ConnectRequest((builder) => builder.publicToken = publicToken);

    await _api.createBank(connectRequest: request).orApiError();
  });

  /// Reopening an existing connection: Plaid hands back no new public token, so there is nothing
  /// to post - the item is repaired in place and the list just needs re-reading.
  Future<bool> reconnect(String memberId) => _write(() async {
    final response = await _api.createUpdateLinkToken(id: memberId).orApiError();

    await ref.read(plaidLinkFlowProvider).open(response.data!.linkToken);
  });

  Future<bool> setSync(BankAccount account, {required bool sync}) =>
      _updateAccount(account.id, BankAccountRequest((builder) => builder.sync_ = sync));

  /// A null budget unassigns, putting the balance back into Spendable.
  Future<bool> assignBudget(BankAccount account, String? budgetId) =>
      _updateAccount(account.id, BankAccountRequest((builder) => builder.budgetId = budgetId));

  /// Two years of history, queued. There is no completion signal, so the user pulls to refresh.
  Future<bool> syncHistory(String memberId) => _write(() => _api.syncBank(id: memberId).orApiError());

  BanksApi get _api => ref.read(apiProvider).getBanksApi();

  Future<bool> _updateAccount(String id, BankAccountRequest request) =>
      _write(() => _api.updateBankAccount(id: id, bankAccountRequest: request).orApiError());

  Future<bool> _write(Future<void> Function() write) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(write);

    if (state.hasError) return false;

    ref.invalidate(bankMembersProvider);

    return true;
  }
}
