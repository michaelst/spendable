import 'package:flutter_test/flutter_test.dart';
import 'package:spendable/finance_kit/wallet.g.dart';
import 'package:spendable/finance_kit/wallet_mapper.dart';
import 'package:spendable_api/spendable_api.dart';

WalletCharge _charge({
  String amount = '20.00',
  WalletCreditDebit creditDebit = WalletCreditDebit.debit,
  String date = '2026-08-01',
  bool pending = false,
}) => WalletCharge(
  accountExternalId: 'apple-card',
  externalId: 'txn-1',
  amount: amount,
  creditDebit: creditDebit,
  date: date,
  name: 'Coffee',
  pending: pending,
);

WalletAccount _account({
  WalletAccountKind kind = WalletAccountKind.creditCard,
  String balance = '42.00',
  WalletCreditDebit creditDebit = WalletCreditDebit.debit,
}) => WalletAccount(
  externalId: 'apple-card',
  name: 'Apple Card',
  kind: kind,
  balance: balance,
  creditDebit: creditDebit,
);

WalletChanges _changes({
  List<WalletAccount>? accounts,
  List<WalletCharge>? inserted,
  List<WalletCharge>? updated,
  List<String>? deleted,
}) => WalletChanges(
  accounts: accounts ?? [_account()],
  inserted: inserted ?? const [],
  updated: updated ?? const [],
  deleted: deleted ?? const [],
  historyToken: 'tok-2',
);

void main() {
  // The sign is the server's decision, so nothing here may quietly make it for it.
  test('amounts go up unsigned, with the direction beside them', () {
    final changes = buildChanges(
      _changes(
        inserted: [
          _charge(),
          _charge(creditDebit: WalletCreditDebit.credit),
        ],
      ),
      historyTokenBefore: 'tok-1',
    );

    expect(changes.inserted!.map((charge) => charge.amount), ['20.00', '20.00']);
    expect(changes.inserted!.map((charge) => charge.creditDebitIndicator.name), ['debit', 'credit']);
  });

  test('carries both tokens, so the server can refuse a batch from the wrong place', () {
    final changes = buildChanges(_changes(), historyTokenBefore: 'tok-1');

    expect(changes.historyTokenBefore, 'tok-1');
    expect(changes.historyTokenAfter, 'tok-2');
  });

  test('a first read starts from nowhere', () {
    expect(buildChanges(_changes(), historyTokenBefore: null).historyTokenBefore, isNull);
  });

  test('account kinds arrive in the words the rest of the API uses', () {
    final kinds = [WalletAccountKind.creditCard, WalletAccountKind.cash, WalletAccountKind.savings];

    final changes = buildChanges(
      _changes(accounts: kinds.map((kind) => _account(kind: kind)).toList()),
      historyTokenBefore: null,
    );

    expect(changes.accounts.map((account) => account.kind.name), [
      FinanceKitAccountKindEnum.creditCard.name,
      FinanceKitAccountKindEnum.cash.name,
      FinanceKitAccountKindEnum.savings.name,
    ]);
  });

  test('dates cross as dates rather than as whatever the device formatted', () {
    final changes = buildChanges(_changes(inserted: [_charge(date: '2026-02-09')]), historyTokenBefore: null);

    final date = changes.inserted!.single.date;

    expect([date.year, date.month, date.day], [2026, 2, 9]);
  });

  test('settled charges travel as updates, reversed ones as ids', () {
    final changes = buildChanges(
      _changes(updated: [_charge(pending: false)], deleted: ['txn-9']),
      historyTokenBefore: null,
    );

    expect(changes.updated!.single.pending, isFalse);
    expect(changes.deleted!.toList(), ['txn-9']);
  });
}
