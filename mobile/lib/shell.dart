import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'banks/banks_screen.dart';
import 'budgets/budgets_screen.dart';
import 'selected_tab.dart';
import 'splits/splits_screen.dart';
import 'transactions/transactions_screen.dart';

/// IndexedStack rather than a swapped child, so switching tabs keeps each screen's scroll
/// position and its loaded pages.
class Shell extends ConsumerWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(selectedTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: tab.index,
        children: const [BudgetsScreen(), TransactionsScreen(), SplitsScreen(), BanksScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.index,
        onDestinationSelected: (index) => ref.read(selectedTabProvider.notifier).select(AppTab.values[index]),
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
