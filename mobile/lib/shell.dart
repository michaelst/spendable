import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'banks/banks_screen.dart';
import 'budgets/budgets_screen.dart';
import 'finance_kit/wallet_sync.dart';
import 'splits/splits_screen.dart';
import 'transactions/transactions_screen.dart';

/// IndexedStack rather than a swapped child, so switching tabs keeps each screen's scroll
/// position and its loaded pages.
class Shell extends ConsumerStatefulWidget {
  const Shell({super.key});

  @override
  ConsumerState<Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<Shell> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    // Here rather than in the app, so nothing reads Wallet before there is a signed-in user to
    // send it to. Nothing renders it; it only has to be alive.
    ref.watch(walletAutoSyncProvider);

    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [BudgetsScreen(), TransactionsScreen(), SplitsScreen(), BanksScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            key: Key('tab-budgets'),
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Budgets',
          ),
          NavigationDestination(
            key: Key('tab-transactions'),
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            key: Key('tab-splits'),
            icon: Icon(Icons.call_split_outlined),
            selectedIcon: Icon(Icons.call_split),
            label: 'Splits',
          ),
          NavigationDestination(
            key: Key('tab-banks'),
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Banks',
          ),
        ],
      ),
    );
  }
}
