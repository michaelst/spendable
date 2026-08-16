import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendable/design/theme.dart';
import 'package:spendable/api/api_client.dart';
import 'package:spendable/banks/banks_screen.dart';
import 'package:spendable/banks/pending_plaid_session.dart';
import 'package:spendable/banks/plaid_link_flow.dart';
import 'package:spendable/finance_kit/wallet.g.dart';
import 'package:spendable/finance_kit/wallet_sync.dart';

import '../support/fakes.dart';

class FakePlaidLinkFlow implements PlaidLinkFlow {
  FakePlaidLinkFlow([this.publicToken]);

  /// Null stands for the user backing out of Link.
  final String? publicToken;

  final opened = <String>[];
  final resumed = <String>[];

  @override
  Future<String?> open(String linkToken) async {
    opened.add(linkToken);

    return publicToken;
  }

  @override
  Future<String?> resume(String redirectUri) async {
    resumed.add(redirectUri);

    return publicToken;
  }
}

class FakePendingPlaidSession implements PendingPlaidSession {
  FakePendingPlaidSession([this.kind]);

  PlaidSessionKind? kind;

  @override
  Future<PlaidSessionKind?> read() async => kind;

  @override
  Future<void> start(PlaidSessionKind value) async => kind = value;

  @override
  Future<void> clear() async => kind = null;
}

Map<String, Object?> _account(
  String id,
  String name, {
  bool sync = true,
  String? budgetId,
  String balance = '120.00',
}) => {
  'id': id,
  'name': name,
  'number': '4321',
  'type': 'depository',
  'sub_type': 'checking',
  'balance': balance,
  'sync': sync,
  'budget_id': budgetId,
};

Map<String, Object?> _member({String status = 'CONNECTED', List<Map<String, Object?>>? accounts}) => {
  'id': 'bkm_1',
  'name': 'Chase',
  'provider': 'Plaid',
  'status': status,
  'has_logo': false,
  'bank_accounts': accounts ?? [_account('bka_1', 'Checking')],
};

const _budgets = [
  {
    'id': 'bgt_rent',
    'name': 'Rent',
    'type': 'envelope',
    'balance': '900.00',
    'budgeted_amount': '1000.00',
    'archived_at': null,
  },
];

class FakeWallet implements Wallet {
  FakeWallet({this.available = true, this.granted = true});

  final bool available;

  /// What the user taps in the system prompt.
  final bool granted;

  var authorization = WalletAuthorization.notDetermined;
  var requested = false;
  final reads = <String?>[];

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<WalletAuthorization> authorizationStatus() async => authorization;

  @override
  Future<WalletAuthorization> requestAuthorization() async {
    requested = true;

    return authorization = granted ? WalletAuthorization.authorized : WalletAuthorization.denied;
  }

  @override
  Future<WalletChanges> read(String? historyToken) async {
    reads.add(historyToken);

    return WalletChanges(
      accounts: [
        WalletAccount(
          externalId: 'apple-card',
          name: 'Apple Card',
          kind: WalletAccountKind.creditCard,
          balance: '42.00',
          creditDebit: WalletCreditDebit.debit,
        ),
      ],
      inserted: [],
      updated: [],
      deleted: [],
      historyToken: 'tok-2',
    );
  }
}

Map<String, ({int status, Object? body})> _replies([Map<String, ({int status, Object? body})>? extra]) => {
  'GET /api/banks': (status: 200, body: [_member()]),
  'GET /api/budgets': (status: 200, body: _budgets),
  ...?extra,
};

Future<(FakeApi, FakePlaidLinkFlow)> _pump(
  WidgetTester tester, {
  Map<String, ({int status, Object? body})>? replies,
  FakePlaidLinkFlow? plaid,
  FakePendingPlaidSession? session,
  FakeWallet? wallet,
}) async {
  final api = FakeApi(replies ?? _replies());
  final link = plaid ?? FakePlaidLinkFlow();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiProvider.overrideWithValue(api.build()),
        plaidLinkFlowProvider.overrideWithValue(link),
        pendingPlaidSessionProvider.overrideWithValue(session ?? FakePendingPlaidSession()),
        walletProvider.overrideWithValue(wallet ?? FakeWallet(available: false)),
      ],
      child: MaterialApp(theme: spendableTheme(Brightness.light), home: const BanksScreen()),
    ),
  );

  await tester.pumpAndSettle();

  return (api, link);
}

void main() {
  testWidgets('lists a connection and its accounts once expanded', (tester) async {
    await _pump(tester);

    expect(find.text('Chase'), findsOneWidget);

    await tester.tap(find.text('Chase'));
    await tester.pumpAndSettle();

    expect(find.text('Checking ••••4321'), findsOneWidget);
    expect(find.text(r'$120.00'), findsOneWidget);

    // Opening the bank is what first asks for the budget list, so let that land.
    await tester.pumpAndSettle();
  });

  // Anything other than CONNECTED means Plaid needs the user to go back through Link.
  testWidgets('a broken connection offers a reconnect', (tester) async {
    final (api, link) = await _pump(
      tester,
      replies: _replies({
        'GET /api/banks': (status: 200, body: [_member(status: 'ITEM_LOGIN_REQUIRED')]),
        'POST /api/banks/bkm_1/link_token': (status: 200, body: {'link_token': 'link-repair'}),
      }),
    );

    await tester.tap(find.byKey(const Key('reconnect-bkm_1')));
    await tester.pumpAndSettle();

    expect(link.opened, ['link-repair']);
    // Repairing an item posts nothing back; the list is just re-read.
    expect(api.requests.map((request) => '${request.method} ${request.path}'), contains('GET /api/banks'));
  });

  testWidgets('a healthy connection offers no reconnect', (tester) async {
    await _pump(tester);

    expect(find.byKey(const Key('reconnect-bkm_1')), findsNothing);
  });

  testWidgets('connecting sends the public token Link handed back', (tester) async {
    final (api, link) = await _pump(
      tester,
      plaid: FakePlaidLinkFlow('public-sandbox'),
      replies: _replies({
        'POST /api/banks/link_token': (status: 200, body: {'link_token': 'link-new'}),
        'POST /api/banks': (status: 201, body: _member()),
      }),
    );

    await tester.tap(find.byKey(const Key('connect-bank')));
    await tester.pumpAndSettle();

    expect(link.opened, ['link-new']);
    expect(api.requests.map((request) => '${request.method} ${request.path}'), contains('POST /api/banks'));
  });

  testWidgets('backing out of Link connects nothing', (tester) async {
    final (api, _) = await _pump(
      tester,
      replies: _replies({
        'POST /api/banks/link_token': (status: 200, body: {'link_token': 'link-new'}),
      }),
    );

    await tester.tap(find.byKey(const Key('connect-bank')));
    await tester.pumpAndSettle();

    final posted = api.requests.map((request) => '${request.method} ${request.path}');

    expect(posted, isNot(contains('POST /api/banks')));
  });

  // The limit is checked before Plaid is called, so the user is not sent through Link for nothing.
  testWidgets('being at the bank limit says so without opening Link', (tester) async {
    final (_, link) = await _pump(
      tester,
      replies: _replies({
        'POST /api/banks/link_token': (
          status: 409,
          body: {
            'errors': [
              {'code': 'bank_limit_reached', 'detail': 'no more connections allowed'},
            ],
          },
        ),
      }),
    );

    await tester.tap(find.byKey(const Key('connect-bank')));
    await tester.pumpAndSettle();

    expect(link.opened, isEmpty);
    expect(find.text('no more connections allowed'), findsOneWidget);
  });

  testWidgets('turning sync off updates that account', (tester) async {
    final (api, _) = await _pump(
      tester,
      replies: _replies({
        'PATCH /api/bank_accounts/bka_1': (status: 200, body: _account('bka_1', 'Checking', sync: false)),
      }),
    );

    await tester.tap(find.text('Chase'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('sync-account-bka_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sync-account-bka_1')));
    await tester.pumpAndSettle();

    final patch = api.requests.firstWhere((request) => request.method == 'PATCH');

    expect(patch.data, containsPair('sync', false));
  });

  testWidgets('assigning a budget sends its id', (tester) async {
    final (api, _) = await _pump(
      tester,
      replies: _replies({
        'PATCH /api/bank_accounts/bka_1': (
          status: 200,
          body: _account('bka_1', 'Checking', budgetId: 'bgt_rent'),
        ),
      }),
    );

    await tester.tap(find.text('Chase'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('budget-for-bka_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('budget-for-bka_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rent').last);
    await tester.pumpAndSettle();

    final patch = api.requests.firstWhere((request) => request.method == 'PATCH');

    expect(patch.data, containsPair('budget_id', 'bgt_rent'));
  });

  // Offering it where FinanceKit has nothing to give - below iOS 17.4, or outside the US - would
  // be a dead end.
  testWidgets('offers Apple only where the device can read Wallet', (tester) async {
    await _pump(tester);

    expect(find.byKey(const Key('connect-apple')), findsNothing);
  });

  testWidgets('connecting Apple authorizes and sends the first read', (tester) async {
    final wallet = FakeWallet();

    final (api, _) = await _pump(
      tester,
      wallet: wallet,
      replies: _replies({
        'POST /api/banks/finance_kit': (
          status: 200,
          body: {'id': 'bkm_apple', 'name': 'Apple', 'history_token': null, 'bank_accounts': []},
        ),
        'POST /api/banks/bkm_apple/finance_kit/changes': (
          status: 200,
          body: {'applied': 0, 'history_token': 'tok-2'},
        ),
      }),
    );

    await tester.tap(find.byKey(const Key('connect-apple')));
    await tester.pumpAndSettle();

    expect(wallet.requested, isTrue);
    // Read from where the server says it is, which is nowhere on a first connect.
    expect(wallet.reads, [null]);

    final sent = api.requests.firstWhere((request) => request.path.endsWith('/changes'));

    expect(sent.data, containsPair('history_token_after', 'tok-2'));
  });

  testWidgets('declining Apple sends nothing and says nothing', (tester) async {
    final wallet = FakeWallet(granted: false);

    final (api, _) = await _pump(tester, wallet: wallet);

    await tester.tap(find.byKey(const Key('connect-apple')));
    await tester.pumpAndSettle();

    expect(wallet.reads, isEmpty);
    expect(api.requests.map((request) => request.path), isNot(contains('/api/banks/finance_kit')));
    expect(find.byType(SnackBar), findsNothing);
  });
}
