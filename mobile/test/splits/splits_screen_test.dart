import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendable/design/theme.dart';
import 'package:spendable/api/api_client.dart';
import 'package:spendable/splits/splits_screen.dart';

import '../support/fakes.dart';

Map<String, Object?> _split(String id, String name, {List<Map<String, Object?>>? lines}) => {
  'id': id,
  'name': name,
  'archived_at': null,
  'split_lines':
      lines ??
      [
        {'id': 'spll_1', 'amount': '-12.00', 'budget_id': 'bgt_food'},
        {'id': 'spll_2', 'amount': '-8.00', 'budget_id': 'bgt_fun'},
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

Map<String, ({int status, Object? body})> _replies([Map<String, ({int status, Object? body})>? extra]) => {
  'GET /api/splits': (status: 200, body: [_split('spl_1', 'Payday')]),
  'GET /api/budgets': (status: 200, body: _budgets),
  ...?extra,
};

Future<FakeApi> _pump(WidgetTester tester, {Map<String, ({int status, Object? body})>? replies}) async {
  final api = FakeApi(replies ?? _replies());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [apiProvider.overrideWithValue(api.build())],
      child: MaterialApp(theme: spendableTheme(Brightness.light), home: const SplitsScreen()),
    ),
  );

  await tester.pumpAndSettle();

  return api;
}

void main() {
  testWidgets('lists a split with its line count and total', (tester) async {
    await _pump(tester);

    expect(find.text('Payday'), findsOneWidget);
    expect(find.text('2 lines'), findsOneWidget);
    expect(find.text(r'-$20.00'), findsOneWidget);
  });

  testWidgets('opening a split loads its lines into the form', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Payday'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('split-amount-0')), findsOneWidget);
    expect(find.byKey(const Key('split-amount-1')), findsOneWidget);
  });

  // Sending the whole set is how the server decides what to keep, add and delete.
  testWidgets('removing a line saves the remaining set', (tester) async {
    final api = await _pump(
      tester,
      replies: _replies({
        'PATCH /api/splits/spl_1': (
          status: 200,
          body: _split(
            'spl_1',
            'Payday',
            lines: [
              {'id': 'spll_1', 'amount': '-12.00', 'budget_id': 'bgt_food'},
            ],
          ),
        ),
      }),
    );

    await tester.tap(find.text('Payday'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('split-remove-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('split-save')));
    await tester.pumpAndSettle();

    final patch = api.requests.firstWhere((request) => request.method == 'PATCH');
    final sent = patch.data! as Map<String, dynamic>;

    expect(sent['split_lines'], [
      {'id': 'spll_1', 'amount': '-12.00', 'budget_id': 'bgt_food'},
    ]);
  });

  // A handful of splits, so archiving several is N requests rather than a bulk endpoint.
  testWidgets('archiving a selection sends one request each', (tester) async {
    final api = await _pump(
      tester,
      replies: _replies({
        'GET /api/splits': (status: 200, body: [_split('spl_1', 'Payday'), _split('spl_2', 'Rent')]),
        'DELETE /api/splits/spl_1': (status: 200, body: _split('spl_1', 'Payday')),
        'DELETE /api/splits/spl_2': (status: 200, body: _split('spl_2', 'Rent')),
      }),
    );

    await tester.longPress(find.byKey(const Key('split-spl_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('select-split-spl_2')));
    await tester.pumpAndSettle();

    expect(find.text('Archive (2)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('archive-selected')));
    await tester.pumpAndSettle();

    final deleted = api.requests
        .where((request) => request.method == 'DELETE')
        .map((request) => request.path);

    expect(deleted, ['/api/splits/spl_1', '/api/splits/spl_2']);
    expect(find.byKey(const Key('archive-selected')), findsNothing);
  });

  testWidgets('a rejected save keeps the sheet open with the error on the field', (tester) async {
    await _pump(
      tester,
      replies: _replies({
        'PATCH /api/splits/spl_1': (
          status: 422,
          body: {
            'errors': [
              {
                'code': 'invalid',
                'detail': "can't be blank",
                'source': {'pointer': '/name'},
              },
            ],
          },
        ),
      }),
    );

    await tester.tap(find.text('Payday'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('split-name')), '');
    await tester.tap(find.byKey(const Key('split-save')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('split-save')), findsOneWidget);
    expect(find.text("can't be blank"), findsOneWidget);
  });
}
