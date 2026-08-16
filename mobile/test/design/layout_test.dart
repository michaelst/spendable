import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendable/api/api_client.dart';
import 'package:spendable/budgets/budgets_screen.dart';
import 'package:spendable/design/theme.dart';
import 'package:spendable/shell.dart';
import 'package:spendable_api/spendable_api.dart';

/// Enough of every list to fill a screen. Nothing here is asserted on - the point is to lay the
/// whole app out and let an overflow throw.
class _Api implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream, Future<void>? cancel) async {
    final body = switch (options.path) {
      '/api/budgets/summary' => {
        'month': '2026-08-01',
        'current_month': true,
        'spendable': '1284.55',
        'allocated_total': '4200.00',
        'spent_total': '2915.45',
        'credit_card_balance': '1204.66',
        'budgets': [
          {
            'id': 'b1',
            'name': 'Groceries',
            'type': 'envelope',
            'balance': '142.18',
            'budgeted_amount': '500.00',
            'archived_at': null,
          },
          {
            'id': 'b2',
            'name': 'Dining out',
            'type': 'envelope',
            'balance': '-63.40',
            'budgeted_amount': '200.00',
            'archived_at': null,
          },
          {
            'id': 'b3',
            'name': 'Emergency fund',
            'type': 'goal',
            'balance': '1500.00',
            'budgeted_amount': '5000.00',
            'archived_at': null,
          },
          {
            'id': 'b4',
            'name': 'Amazon',
            'type': 'tracking',
            'balance': '0.00',
            'budgeted_amount': null,
            'archived_at': null,
          },
        ],
        'spent': {'b1': '-357.82', 'b2': '-263.40', 'b3': '0.00', 'b4': '-88.02'},
        'spent_by_month': [
          {'month': '2026-08-01', 'spent': '-2915.45'},
          {'month': '2026-07-01', 'spent': '-2480.19'},
        ],
      },
      '/api/transactions' => [
        {
          'id': 't1',
          'name': 'Sunset Boulevard Wine & Provisions',
          'amount': '-142.87',
          'date': '2026-08-14',
          'reviewed': false,
          'excluded': false,
          'note': null,
          'transfer_id': null,
          'budget_allocations': <Object>[],
          'source': null,
        },
        {
          'id': 't2',
          'name': 'Direct deposit',
          'amount': '2410.00',
          'date': '2026-08-14',
          'reviewed': true,
          'excluded': false,
          'note': null,
          'transfer_id': null,
          'budget_allocations': <Object>[],
          'source': null,
        },
      ],
      '/api/splits' => [
        {
          'id': 's1',
          'name': 'Payday',
          'archived_at': null,
          'split_lines': [
            {'id': 'sl1', 'budget_id': 'b1', 'amount': '100.00'},
          ],
        },
      ],
      '/api/banks' => [
        {
          'id': 'm1',
          'name': 'Chase',
          'provider': 'Plaid',
          'status': 'CONNECTED',
          'has_logo': false,
          'bank_accounts': [
            {
              'id': 'a1',
              'name': 'Checking',
              'number': '4021',
              'type': 'depository',
              'sub_type': 'checking',
              'balance': '1204.66',
              'sync': true,
              'budget_id': null,
            },
          ],
        },
      ],
      _ => <Object>[],
    };

    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

// A phone is narrower than the 800x600 the other tests run at, and the editorial type is set large
// enough that the difference is where a row runs out of room.
void main() {
  for (final brightness in Brightness.values) {
    testWidgets('every screen and sheet fits a phone in ${brightness.name}', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiProvider.overrideWithValue(
              SpendableApi(dio: Dio(BaseOptions(baseUrl: 'https://x.test'))..httpClientAdapter = _Api()),
            ),
          ],
          child: MaterialApp(theme: spendableTheme(brightness), home: const Shell()),
        ),
      );

      await tester.pumpAndSettle();

      for (final tab in ['tab-transactions', 'tab-splits', 'tab-banks', 'tab-budgets']) {
        await tester.tap(find.byKey(Key(tab)));
        await tester.pumpAndSettle();
      }

      // The month menu, hung off the large title.
      await tester.tap(find.byKey(const Key('month-picker')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(200, 700));
      await tester.pumpAndSettle();

      // A budget sheet, and an edit of an existing row.
      await tester.tap(find.byKey(const Key('new-budget')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(200, 60));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open-account')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('account-back')));
      await tester.pumpAndSettle();

      // Last, because reaching a row further down the list scrolls the large title away and the
      // band's own buttons go with it. Scrolled to rather than ensured visible: goals sort to the
      // end, and a sliver list has not built the rows down there yet.
      await tester.scrollUntilVisible(
        find.text('Emergency fund'),
        200,
        scrollable: find.descendant(of: find.byType(BudgetsScreen), matching: find.byType(Scrollable)).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Emergency fund'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(200, 60));
      await tester.pumpAndSettle();

      // The transaction detail sheet, the filters sheet, and the bulk bar.
      await tester.tap(find.byKey(const Key('tab-transactions')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open-filters')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(200, 60));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('transaction-t1')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(200, 60));
      await tester.pumpAndSettle();

      await tester.longPress(find.byKey(const Key('transaction-t1')));
      await tester.pumpAndSettle();
    });
  }
}
