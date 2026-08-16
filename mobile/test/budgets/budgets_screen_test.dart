import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendable/design/theme.dart';
import 'package:spendable/api/api_client.dart';
import 'package:spendable/budgets/budgets_screen.dart';

import '../support/fakes.dart';

Map<String, Object?> _budget(
  String id,
  String name, {
  String type = 'envelope',
  String balance = '0.00',
  String? budgetedAmount,
}) => {
  'id': id,
  'name': name,
  'type': type,
  'balance': balance,
  'budgeted_amount': budgetedAmount,
  'archived_at': null,
};

Map<String, Object?> _summary({
  bool currentMonth = true,
  String creditCardBalance = '0.00',
  List<Map<String, Object?>>? budgets,
  Map<String, String>? spent,
}) => {
  'month': '2026-08-01',
  'current_month': currentMonth,
  'spendable': '420.00',
  'allocated_total': '1000.00',
  'spent_total': '250.00',
  'credit_card_balance': creditCardBalance,
  'budgets':
      budgets ??
      [
        _budget('bgt_spendable', 'Spendable'),
        _budget('bgt_food', 'Food', balance: '50.00', budgetedAmount: '200.00'),
      ],
  'spent': spent ?? {'bgt_spendable': '0.00', 'bgt_food': '-150.00'},
  'spent_by_month': [
    {'month': '2026-08-01', 'spent': '-250.00'},
    {'month': '2026-07-01', 'spent': '-310.00'},
  ],
};

Future<FakeApi> _pump(WidgetTester tester, {Map<String, ({int status, Object? body})>? replies}) async {
  final api = FakeApi(replies ?? {'GET /api/budgets/summary': (status: 200, body: _summary())});

  await tester.pumpWidget(
    ProviderScope(
      overrides: [apiProvider.overrideWithValue(api.build())],
      child: MaterialApp(theme: spendableTheme(Brightness.light), home: const BudgetsScreen()),
    ),
  );

  await tester.pumpAndSettle();

  return api;
}

void main() {
  testWidgets('shows the month and the totals behind it', (tester) async {
    await _pump(tester);

    expect(find.text('August 2026'), findsOneWidget);
    expect(find.byKey(const Key('spendable-total')), findsOneWidget);
    expect(find.text(r'$420.00'), findsOneWidget);
    expect(find.text(r'$1,000.00'), findsOneWidget);
  });

  testWidgets('renders a card per budget with its label and footer', (tester) async {
    await _pump(tester);

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('LEFT'), findsWidgets);
    expect(find.text(r'$150.00 of $200.00 spent'), findsOneWidget);
  });

  // Card debt reads as a budget here, but only against the current month.
  testWidgets('sets credit cards apart as a negative balance', (tester) async {
    await _pump(
      tester,
      replies: {'GET /api/budgets/summary': (status: 200, body: _summary(creditCardBalance: '325.50'))},
    );

    expect(find.text('Credit Cards'), findsOneWidget);
    expect(find.text(r'-$325.50'), findsOneWidget);
  });

  testWidgets('leaves credit cards off a past month', (tester) async {
    await _pump(
      tester,
      replies: {
        'GET /api/budgets/summary': (
          status: 200,
          body: _summary(currentMonth: false, creditCardBalance: '325.50'),
        ),
      },
    );

    expect(find.text('Credit Cards'), findsNothing);
    expect(find.byKey(const Key('spendable-total')), findsNothing);
  });

  testWidgets('picking a month re-reads the summary for it', (tester) async {
    final api = await _pump(tester);

    await tester.tap(find.byKey(const Key('month-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('July 2026'));
    await tester.pumpAndSettle();

    expect(api.requests.last.queryParameters['month'], '2026-07-01');
  });

  testWidgets('saving a budget re-reads the whole summary, not just the row', (tester) async {
    final api = await _pump(
      tester,
      replies: {
        'GET /api/budgets/summary': (status: 200, body: _summary()),
        'PATCH /api/budgets/bgt_food': (
          status: 200,
          body: _budget('bgt_food', 'Groceries', balance: '50.00', budgetedAmount: '200.00'),
        ),
      },
    );

    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('budget-name')), 'Groceries');
    await tester.tap(find.byKey(const Key('budget-save')));
    await tester.pumpAndSettle();

    expect(api.requests.map((request) => '${request.method} ${request.path}'), [
      'GET /api/budgets/summary',
      'PATCH /api/budgets/bgt_food',
      'GET /api/budgets/summary',
    ]);
  });

  testWidgets('a rejected save keeps the sheet open with the error on the field', (tester) async {
    await _pump(
      tester,
      replies: {
        'GET /api/budgets/summary': (status: 200, body: _summary()),
        'PATCH /api/budgets/bgt_food': (
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
      },
    );

    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('budget-name')), '');
    await tester.tap(find.byKey(const Key('budget-save')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('budget-save')), findsOneWidget);
    expect(find.text("can't be blank"), findsOneWidget);
  });

  testWidgets('the credit card total is not editable', (tester) async {
    await _pump(
      tester,
      replies: {'GET /api/budgets/summary': (status: 200, body: _summary(creditCardBalance: '325.50'))},
    );

    await tester.tap(find.text('Credit Cards'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('budget-save')), findsNothing);
  });

  // Spendable is whatever the other budgets have not claimed, so there is nothing to edit on it.
  testWidgets('Spendable is not editable', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Spendable').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('budget-save')), findsNothing);
  });

  // Card debt is not an envelope with something left in it, it is what is owed right now.
  testWidgets('reads the credit card total as a balance rather than what is left', (tester) async {
    await _pump(
      tester,
      replies: {'GET /api/budgets/summary': (status: 200, body: _summary(creditCardBalance: '325.50'))},
    );

    expect(find.text('BALANCE'), findsOneWidget);
  });

  testWidgets('no budget says it has no limit set', (tester) async {
    await _pump(
      tester,
      replies: {
        'GET /api/budgets/summary': (
          status: 200,
          body: _summary(
            budgets: [
              _budget('bgt_spendable', 'Spendable'),
              _budget('bgt_amazon', 'Amazon', type: 'tracking'),
            ],
          ),
        ),
      },
    );

    expect(find.text('No limit set'), findsNothing);
  });

  // Envelopes, then goals, then what is only tracked - the grouping does the work a heading would.
  testWidgets('orders the budgets by type with no heading over each group', (tester) async {
    await _pump(
      tester,
      replies: {
        'GET /api/budgets/summary': (
          status: 200,
          body: _summary(
            budgets: [
              _budget('bgt_spendable', 'Spendable'),
              _budget('bgt_amazon', 'Amazon', type: 'tracking'),
              _budget('bgt_vacation', 'Vacation', type: 'goal'),
              _budget('bgt_rent', 'Rent'),
              _budget('bgt_food', 'Food'),
            ],
          ),
        ),
      },
    );

    final rows = ['Food', 'Rent', 'Vacation', 'Amazon'].map((name) => tester.getTopLeft(find.text(name)).dy);

    expect(rows, orderedEquals(rows.toList()..sort()));
  });
}
