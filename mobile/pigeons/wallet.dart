import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/finance_kit/wallet.g.dart',
    swiftOut: 'ios/Runner/FinanceKit/Wallet.g.swift',
    dartPackageName: 'spendable',
  ),
)
/// Whether the user has let the app read their Wallet.
enum WalletAuthorization { notDetermined, denied, authorized }

/// What the account is, in the app's own words rather than FinanceKit's. Nothing emits `savings`
/// yet: FinanceKit does not say which asset accounts are savings, and guessing from the name is
/// how you end up deleting someone's data over a rename.
enum WalletAccountKind { creditCard, cash, savings }

/// Which way money moved. The server puts the sign on, so nothing here is ever negative.
enum WalletCreditDebit { credit, debit }

class WalletAccount {
  WalletAccount({
    required this.externalId,
    required this.name,
    required this.kind,
    required this.balance,
    required this.creditDebit,
  });

  String externalId;
  String name;
  WalletAccountKind kind;

  /// Unsigned, as a decimal string. Doubles do not hold money.
  String balance;
  WalletCreditDebit creditDebit;
}

class WalletCharge {
  WalletCharge({
    required this.accountExternalId,
    required this.externalId,
    required this.amount,
    required this.creditDebit,
    required this.date,
    required this.name,
    required this.pending,
  });

  String accountExternalId;
  String externalId;

  /// Unsigned, as a decimal string.
  String amount;
  WalletCreditDebit creditDebit;

  /// `yyyy-MM-dd`.
  String date;
  String name;
  bool pending;
}

/// One read of Wallet.
class WalletChanges {
  WalletChanges({
    required this.accounts,
    required this.inserted,
    required this.updated,
    required this.deleted,
    required this.historyToken,
  });

  List<WalletAccount> accounts;
  List<WalletCharge> inserted;
  List<WalletCharge> updated;

  /// External ids of charges that were reversed or declined.
  List<String> deleted;

  /// Where this read finished, to be sent back on the next one.
  String historyToken;
}

@HostApi()
abstract class WalletApi {
  /// False below iOS 17.4, outside the US, or wherever FinanceKit has no data to give.
  bool isAvailable();

  @async
  WalletAuthorization authorizationStatus();

  @async
  WalletAuthorization requestAuthorization();

  /// Everything since [historyToken], or everything Wallet holds when it is null. A token
  /// FinanceKit will not take is treated as null rather than as a failure, so a rejected token
  /// costs a backfill and nothing else.
  @async
  WalletChanges read(String? historyToken);
}
