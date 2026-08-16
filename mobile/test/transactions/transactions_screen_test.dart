import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendable/design/glyph_icon.dart';
import 'package:spendable/design/theme.dart';
import 'package:spendable/api/api_client.dart';
import 'package:spendable/transactions/transactions_screen.dart';

import '../support/fakes.dart';

Map<String, Object?> _transaction(
  String id,
  String name, {
  String amount = '-20.00',
  bool reviewed = false,
  bool excluded = false,
  String? transferId,
  List<Map<String, Object?>>? allocations,
}) => {
  'id': id,
  'name': name,
  'amount': amount,
  'date': '2026-08-14',
  'note': null,
  'reviewed': reviewed,
  'excluded': excluded,
  'transfer_id': transferId,
  'source': null,
  'budget_allocations':
      allocations ??
      [
        {'id': 'bal_$id', 'amount': amount, 'budget_id': 'bgt_food'},
      ],
};

const _budgets = [
  {
    'id': 'bgt_food',
    'name': 'Food',
    'type': 'envelope',
    'balance': '50.00',
    'budgeted_amount': '200.00',
    'archived_at': null,
  },
  {
    'id': 'bgt_fun',
    'name': 'Fun',
    'type': 'envelope',
    'balance': '30.00',
    'budgeted_amount': '100.00',
    'archived_at': null,
  },
];

const _splits = [
  {
    'id': 'spl_payday',
    'name': 'Payday',
    'archived_at': null,
    'split_lines': [
      {'id': 'spll_1', 'amount': '-12.00', 'budget_id': 'bgt_food'},
      {'id': 'spll_2', 'amount': '-8.00', 'budget_id': 'bgt_fun'},
    ],
  },
];

Map<String, ({int status, Object? body})> _replies([Map<String, ({int status, Object? body})>? extra]) => {
  'GET /api/transactions': (status: 200, body: [_transaction('txn_1', 'Market')]),
  'GET /api/budgets': (status: 200, body: _budgets),
  'GET /api/splits': (status: 200, body: _splits),
  ...?extra,
};

Future<FakeApi> _pump(WidgetTester tester, {Map<String, ({int status, Object? body})>? replies}) async {
  final api = FakeApi(replies ?? _replies());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [apiProvider.overrideWithValue(api.build())],
      child: MaterialApp(theme: spendableTheme(Brightness.light), home: const TransactionsScreen()),
    ),
  );

  await tester.pumpAndSettle();

  return api;
}

/// The filled circle a reviewed row carries, wherever it is drawn.
int _reviewedMarkers(WidgetTester tester) => tester
    .widgetList<GlyphIcon>(find.byType(GlyphIcon))
    .where((icon) => icon.glyph == Glyph.checkCircleFill)
    .length;

void main() {
  // The API hides reviewed rows unless asked; the screen is a queue and wants them shown.
  testWidgets('asks for reviewed rows and hides excluded ones', (tester) async {
    final api = await _pump(tester);

    expect(api.requests.first.queryParameters['show_reviewed'], true);
    expect(api.requests.first.queryParameters['show_excluded'], false);
  });

  testWidgets('lists a transaction with its date and amount', (tester) async {
    await _pump(tester);

    expect(find.text('Market'), findsOneWidget);
    expect(find.text(r'-$20.00'), findsOneWidget);
    expect(find.textContaining('Aug 14, 2026'), findsOneWidget);
  });

  // Reviewing is what clears the queue, so the row has to leave when it no longer matches.
  testWidgets('a reviewed row drops out of the list when reviewed rows are hidden', (tester) async {
    await _pump(
      tester,
      replies: _replies({
        'PATCH /api/transactions/txn_1': (status: 200, body: _transaction('txn_1', 'Market', reviewed: true)),
      }),
    );

    await tester.tap(find.byKey(const Key('open-filters')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('filter-reviewed')));
    await tester.pumpAndSettle();

    // Dismiss the sheet by tapping its barrier.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('reviewed-txn_1')));
    await tester.pumpAndSettle();

    expect(find.text('Market'), findsNothing);
  });

  testWidgets('a reviewed row stays when reviewed rows are shown', (tester) async {
    await _pump(
      tester,
      replies: _replies({
        'PATCH /api/transactions/txn_1': (status: 200, body: _transaction('txn_1', 'Market', reviewed: true)),
      }),
    );

    await tester.tap(find.byKey(const Key('reviewed-txn_1')));
    await tester.pumpAndSettle();

    expect(find.text('Market'), findsOneWidget);
    expect(_reviewedMarkers(tester), 1);
  });

  testWidgets('selecting two rows offers a transfer', (tester) async {
    final api = await _pump(
      tester,
      replies: _replies({
        'GET /api/transactions': (
          status: 200,
          body: [
            _transaction('txn_1', 'Out'),
            _transaction('txn_2', 'In', amount: '20.00'),
          ],
        ),
        'POST /api/transactions/transfer': (
          status: 200,
          body: [
            _transaction('txn_1', 'Out', transferId: 'txn_2'),
            _transaction('txn_2', 'In', amount: '20.00', transferId: 'txn_1'),
          ],
        ),
      }),
    );

    await tester.longPress(find.byKey(const Key('transaction-txn_1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bulk-transfer')), findsNothing);

    await tester.tap(find.byKey(const Key('select-txn_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bulk-transfer')));
    await tester.pumpAndSettle();

    expect(api.requests.last.data, containsPair('transaction_ids', ['txn_1', 'txn_2']));
    expect(find.textContaining('Transfer'), findsWidgets);
  });

  testWidgets('a refused transfer says why and leaves the rows alone', (tester) async {
    await _pump(
      tester,
      replies: _replies({
        'GET /api/transactions': (
          status: 200,
          body: [_transaction('txn_1', 'Out'), _transaction('txn_2', 'Also out')],
        ),
        'POST /api/transactions/transfer': (
          status: 409,
          body: {
            'errors': [
              {'code': 'transfer_not_allowed', 'detail': 'needs one leaving and one arriving'},
            ],
          },
        ),
      }),
    );

    await tester.longPress(find.byKey(const Key('transaction-txn_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('select-txn_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bulk-transfer')));
    await tester.pumpAndSettle();

    expect(find.text('needs one leaving and one arriving'), findsOneWidget);
  });

  testWidgets('bulk review applies to everything selected and clears the selection', (tester) async {
    final api = await _pump(
      tester,
      replies: _replies({
        'GET /api/transactions': (
          status: 200,
          body: [_transaction('txn_1', 'Market'), _transaction('txn_2', 'Coffee')],
        ),
        'PATCH /api/transactions/bulk': (
          status: 200,
          body: {
            'transactions': [
              _transaction('txn_1', 'Market', reviewed: true),
              _transaction('txn_2', 'Coffee', reviewed: true),
            ],
            'failed': <Object>[],
          },
        ),
      }),
    );

    await tester.longPress(find.byKey(const Key('transaction-txn_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('select-txn_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bulk-review')));
    await tester.pumpAndSettle();

    expect(api.requests.last.data, containsPair('reviewed', true));
    expect(find.byKey(const Key('bulk-review')), findsNothing);
    expect(_reviewedMarkers(tester), 2);
  });

  // A bulk delete is applied per transaction, so the ones that failed have to stay on screen.
  testWidgets('bulk delete keeps the rows the server could not delete', (tester) async {
    await _pump(
      tester,
      replies: _replies({
        'GET /api/transactions': (
          status: 200,
          body: [_transaction('txn_1', 'Market'), _transaction('txn_2', 'Coffee')],
        ),
        'POST /api/transactions/bulk/delete': (
          status: 200,
          body: {
            'transactions': [_transaction('txn_1', 'Market')],
            'failed': [
              {'id': 'txn_2', 'code': 'transaction_not_found'},
            ],
          },
        ),
      }),
    );

    await tester.longPress(find.byKey(const Key('transaction-txn_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('select-txn_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bulk-delete')));
    await tester.pumpAndSettle();

    expect(find.text('Market'), findsNothing);
    expect(find.text('Coffee'), findsOneWidget);
  });
}
