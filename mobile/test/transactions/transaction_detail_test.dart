import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendable/design/theme.dart';
import 'package:spendable/api/api_client.dart';
import 'package:spendable/transactions/transactions_screen.dart';

import '../support/fakes.dart';

Map<String, Object?> _transaction({
  String amount = '-20.00',
  String? transferId,
  List<Map<String, Object?>>? allocations,
}) => {
  'id': 'txn_1',
  'name': 'Market',
  'amount': amount,
  'date': '2026-08-14',
  'note': null,
  'reviewed': false,
  'excluded': false,
  'transfer_id': transferId,
  'source': null,
  'budget_allocations':
      allocations ??
      [
        {'id': 'bal_1', 'amount': amount, 'budget_id': 'bgt_food'},
      ],
};

const _budgets = [
  {
    'id': 'bgt_food',
    'name': 'Food',
    'type': 'envelope',
    'balance': '50.00',
    'budgeted_amount': '200.00',
    'rollover': true,
    'archived_at': null,
  },
  {
    'id': 'bgt_fun',
    'name': 'Fun',
    'type': 'envelope',
    'balance': '30.00',
    'budgeted_amount': '100.00',
    'rollover': true,
    'archived_at': null,
  },
];

const _splits = [
  {
    'id': 'spl_payday',
    'name': 'Payday',
    'rollover': true,
    'archived_at': null,
    'split_lines': [
      {'id': 'spll_1', 'amount': '-12.00', 'budget_id': 'bgt_food'},
      {'id': 'spll_2', 'amount': '-8.00', 'budget_id': 'bgt_fun'},
    ],
  },
];

/// Opens the sheet the way the screen does, so the detail is exercised against a real list.
Future<FakeApi> _open(
  WidgetTester tester, {
  Map<String, Object?>? transaction,
  Map<String, ({int status, Object? body})>? extra,
}) async {
  final api = FakeApi({
    'GET /api/transactions': (status: 200, body: [transaction ?? _transaction()]),
    'GET /api/budgets': (status: 200, body: _budgets),
    'GET /api/splits': (status: 200, body: _splits),
    ...?extra,
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [apiProvider.overrideWithValue(api.build())],
      child: MaterialApp(theme: spendableTheme(Brightness.light), home: const TransactionsScreen()),
    ),
  );

  await tester.pumpAndSettle();
  await tester.tap(find.text('Market'));
  await tester.pumpAndSettle();

  return api;
}

void main() {
  // A transaction with one allocation splits nothing, so only the budget is worth asking about.
  testWidgets('a single allocation offers just the budget', (tester) async {
    await _open(tester);

    expect(find.byKey(const Key('allocation-budget-0')), findsOneWidget);
    expect(find.byKey(const Key('allocation-amount-0')), findsNothing);
    expect(find.text('SPEND FROM'), findsOneWidget);
  });

  testWidgets('money coming in reads as adding to a budget', (tester) async {
    await _open(tester, transaction: _transaction(amount: '20.00'));

    expect(find.text('ADD TO'), findsOneWidget);
  });

  testWidgets('a split transaction shows an amount against each budget', (tester) async {
    await _open(
      tester,
      transaction: _transaction(
        allocations: [
          {'id': 'bal_1', 'amount': '-12.00', 'budget_id': 'bgt_food'},
          {'id': 'bal_2', 'amount': '-8.00', 'budget_id': 'bgt_fun'},
        ],
      ),
    );

    expect(find.byKey(const Key('allocation-amount-0')), findsOneWidget);
    expect(find.byKey(const Key('allocation-amount-1')), findsOneWidget);
  });

  // A single allocation carries the whole amount, so the line follows the amount field.
  testWidgets('saving one allocation sends the whole amount against it', (tester) async {
    final api = await _open(
      tester,
      extra: {'PATCH /api/transactions/txn_1': (status: 200, body: _transaction(amount: '-25.00'))},
    );

    await tester.enterText(find.byKey(const Key('transaction-amount')), '-25.00');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('transaction-save')));
    await tester.pumpAndSettle();

    final sent = api.requests.last.data! as Map<String, dynamic>;

    expect(sent['amount'], '-25.00');
    expect(sent['budget_allocations'], [
      {'id': 'bal_1', 'amount': '-25.00', 'budget_id': 'bgt_food'},
    ]);
  });

  testWidgets('applying a split replaces the lines with the split lines', (tester) async {
    final api = await _open(
      tester,
      extra: {'PATCH /api/transactions/txn_1': (status: 200, body: _transaction())},
    );

    await tester.tap(find.byKey(const Key('apply-split')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('split-spl_payday')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('allocation-amount-1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('transaction-save')));
    await tester.pumpAndSettle();

    final sent = api.requests.last.data! as Map<String, dynamic>;

    // The split's own line ids belong to the split, not to this transaction.
    expect(sent['budget_allocations'], [
      {'amount': '-12.00', 'budget_id': 'bgt_food'},
      {'amount': '-8.00', 'budget_id': 'bgt_fun'},
    ]);
  });

  testWidgets('removing a transfer closes the sheet and refreshes the row', (tester) async {
    final api = await _open(
      tester,
      transaction: _transaction(transferId: 'txn_2'),
      extra: {'DELETE /api/transactions/txn_1/transfer': (status: 200, body: _transaction())},
    );

    await tester.ensureVisible(find.byKey(const Key('remove-transfer')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('remove-transfer')));
    await tester.pumpAndSettle();

    expect(api.requests.map((request) => request.method), contains('DELETE'));
    expect(find.byKey(const Key('transaction-save')), findsNothing);
    expect(find.textContaining('Transfer'), findsNothing);
  });

  testWidgets('a rejected save keeps the sheet open with the error on the line', (tester) async {
    await _open(
      tester,
      transaction: _transaction(
        allocations: [
          {'id': 'bal_1', 'amount': '-12.00', 'budget_id': 'bgt_food'},
          {'id': 'bal_2', 'amount': '-8.00', 'budget_id': 'bgt_fun'},
        ],
      ),
      extra: {
        'PATCH /api/transactions/txn_1': (
          status: 422,
          body: {
            'errors': [
              {
                'code': 'invalid',
                'detail': 'is invalid',
                'source': {'pointer': '/budget_allocations/1/amount'},
              },
            ],
          },
        ),
      },
    );

    await tester.enterText(find.byKey(const Key('allocation-amount-1')), 'nope');
    await tester.tap(find.byKey(const Key('transaction-save')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('transaction-save')), findsOneWidget);
    expect(find.text('is invalid'), findsOneWidget);
  });
}
