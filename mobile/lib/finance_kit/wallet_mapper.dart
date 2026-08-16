import 'package:built_collection/built_collection.dart';
import 'package:spendable_api/spendable_api.dart';

import 'wallet.g.dart';

/// Turns what the device read out of Wallet into the batch the server takes.
///
/// Nothing is decided here beyond naming: the amounts stay unsigned and the server puts the sign
/// on, so there is one place that says which way money went rather than two that can disagree.
FinanceKitChanges buildChanges(WalletChanges changes, {required String? historyTokenBefore}) {
  return FinanceKitChanges(
    (builder) => builder
      ..historyTokenBefore = historyTokenBefore
      ..historyTokenAfter = changes.historyToken
      ..accounts = ListBuilder(changes.accounts.map(buildAccount))
      ..inserted = ListBuilder(changes.inserted.map(buildCharge))
      ..updated = ListBuilder(changes.updated.map(buildCharge))
      ..deleted = ListBuilder(changes.deleted),
  );
}

FinanceKitAccount buildAccount(WalletAccount account) {
  return FinanceKitAccount(
    (builder) => builder
      ..externalId = account.externalId
      ..name = account.name
      ..kind = _kinds[account.kind]!
      ..balance = account.balance
      ..creditDebitIndicator = _indicators[account.creditDebit]!,
  );
}

FinanceKitCharge buildCharge(WalletCharge charge) {
  return FinanceKitCharge(
    (builder) => builder
      ..accountExternalId = charge.accountExternalId
      ..externalId = charge.externalId
      ..amount = charge.amount
      ..creditDebitIndicator = _chargeIndicators[charge.creditDebit]!
      // The plugin formats it yyyy-MM-dd, which is the one shape the generated Date takes.
      ..date = DateTime.parse(charge.date).toDate()
      ..name = charge.name
      ..pending = charge.pending,
  );
}

const _kinds = {
  WalletAccountKind.creditCard: FinanceKitAccountKindEnum.creditCard,
  WalletAccountKind.cash: FinanceKitAccountKindEnum.cash,
  WalletAccountKind.savings: FinanceKitAccountKindEnum.savings,
};

// Two enums saying the same thing, because the generator makes one per schema that declares it.
const _indicators = {
  WalletCreditDebit.credit: FinanceKitAccountCreditDebitIndicatorEnum.credit,
  WalletCreditDebit.debit: FinanceKitAccountCreditDebitIndicatorEnum.debit,
};

const _chargeIndicators = {
  WalletCreditDebit.credit: FinanceKitChargeCreditDebitIndicatorEnum.credit,
  WalletCreditDebit.debit: FinanceKitChargeCreditDebitIndicatorEnum.debit,
};
