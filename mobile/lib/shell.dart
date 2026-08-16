import 'package:flutter/material.dart';

import 'banks/banks_screen.dart';
import 'budgets/budgets_screen.dart';
import 'splits/splits_screen.dart';
import 'transactions/transactions_screen.dart';

/// IndexedStack rather than a swapped child, so switching tabs keeps each screen's scroll
/// position and its loaded pages.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
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
