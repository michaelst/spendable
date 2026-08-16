import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'banks/banks_screen.dart';
import 'budgets/budgets_screen.dart';
import 'design/glass_tab_bar.dart';
import 'design/glyph_icon.dart';
import 'design/tokens.dart';
import 'finance_kit/wallet_sync.dart';
import 'splits/splits_screen.dart';
import 'transactions/transactions_screen.dart';

const _destinations = [
  TabDestination(key: Key('tab-budgets'), icon: Glyph.money, fill: Glyph.moneyFill, label: 'Budgets'),
  TabDestination(
    key: Key('tab-transactions'),
    icon: Glyph.creditCard,
    fill: Glyph.creditCardFill,
    label: 'Transactions',
  ),
  TabDestination(key: Key('tab-splits'), icon: Glyph.copy, fill: Glyph.copyFill, label: 'Splits'),
  TabDestination(key: Key('tab-banks'), icon: Glyph.bank, fill: Glyph.bankFill, label: 'Banks'),
];

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
    final media = MediaQuery.of(context);

    // Here rather than in the app, so nothing reads Wallet before there is a signed-in user to
    // send it to. Nothing renders it; it only has to be alive.
    ref.watch(walletAutoSyncProvider);

    return BackdropGroup(
      child: Scaffold(
        backgroundColor: SpendableColors.of(context).ground,
        // The bar is outside every screen's own Scaffold, and text with no Material above it falls
        // back to the framework's error style rather than the theme's.
        body: Stack(
          children: [
            // The bar floats over the list rather than sitting beside it, so what every screen has to
            // clear is handed down as padding instead of each one knowing the bar's height.
            MediaQuery(
              data: media.copyWith(
                padding: media.padding.copyWith(
                  bottom: math.max(media.padding.bottom, SpendableChrome.tabBarExtent),
                ),
              ),
              child: IndexedStack(
                index: _tab,
                children: const [BudgetsScreen(), TransactionsScreen(), SplitsScreen(), BanksScreen()],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GlassTabBar(
                destinations: _destinations,
                selectedIndex: _tab,
                onSelected: (index) => setState(() => _tab = index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
