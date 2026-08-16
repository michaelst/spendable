import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';
import 'banks_providers.dart';
import 'pending_plaid_session.dart';
import 'plaid_link_flow.dart';

part 'banks_controller.g.dart';

/// Connecting banks and deciding what each account does. Kept alive because a resumed OAuth
/// redirect reaches it before any screen is watching, and an auto-disposed notifier would be
/// collected out from under the write.
@Riverpod(keepAlive: true)
class BanksController extends _$BanksController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// The bank limit is checked before Plaid is called, so a refusal comes back without the user
  /// having been sent through Link for nothing.
  Future<bool> connect() => _write(() async {
    final response = await _api.createLinkToken().orApiError();

    await _session.start(PlaidSessionKind.connect);

    await _exchange(await ref.read(plaidLinkFlowProvider).open(response.data!.linkToken));
  });

  /// Reopening an existing connection: Plaid hands back no token worth exchanging, so the item is
  /// repaired in place and the list just needs re-reading.
  Future<bool> reconnect(String memberId) => _write(() async {
    final response = await _api.createUpdateLinkToken(id: memberId).orApiError();

    await _session.start(PlaidSessionKind.reconnect);

    await ref.read(plaidLinkFlowProvider).open(response.data!.linkToken);

    await _session.clear();
  });

  /// iOS terminated the app while the user was on the bank's OAuth page, and the redirect has
  /// brought it back. Only a connect has anything left to finish.
  Future<bool> resumeOAuth(String redirectUri) => _write(() async {
    final kind = await _session.read();

    if (kind == null) return;

    final publicToken = await ref.read(plaidLinkFlowProvider).resume(redirectUri);

    if (kind == PlaidSessionKind.connect) {
      await _exchange(publicToken);
    } else {
      await _session.clear();
    }
  });

  Future<bool> setSync(BankAccount account, {required bool sync}) =>
      _updateAccount(account.id, BankAccountRequest((builder) => builder.sync_ = sync));

  /// A null budget unassigns, putting the balance back into Spendable.
  Future<bool> assignBudget(BankAccount account, String? budgetId) =>
      _updateAccount(account.id, BankAccountRequest((builder) => builder.budgetId = budgetId));

  /// Two years of history, queued. There is no completion signal, so the user pulls to refresh.
  Future<bool> syncHistory(String memberId) => _write(() => _api.syncBank(id: memberId).orApiError());

  BanksApi get _api => ref.read(apiProvider).getBanksApi();

  PendingPlaidSession get _session => ref.read(pendingPlaidSessionProvider);

  /// Cleared before the exchange rather than after, so a failure there cannot leave a session
  /// pending that the next launch would try to finish again.
  Future<void> _exchange(String? publicToken) async {
    await _session.clear();

    if (publicToken == null) return;

    final request = ConnectRequest((builder) => builder.publicToken = publicToken);

    await _api.createBank(connectRequest: request).orApiError();
  }

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
