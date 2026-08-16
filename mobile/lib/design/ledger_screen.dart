import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'nav_band.dart';
import 'tokens.dart';

/// The shape every screen takes: a band at the top, a bouncing list under it, and whatever the
/// screen needs pinned to the bottom floating over the last of it.
class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key, required this.band, required this.slivers, this.onRefresh, this.bottomBar});

  final NavBand band;
  final List<Widget> slivers;
  final Future<void> Function()? onRefresh;

  /// Floats over the list, above the tab bar. The list already clears both.
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);

    return Scaffold(
      backgroundColor: colors.ground,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              band,
              if (onRefresh case final onRefresh?) CupertinoSliverRefreshControl(onRefresh: onRefresh),
              ...slivers,
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.paddingOf(context).bottom + SpendableSpace.block),
              ),
            ],
          ),
          if (bottomBar case final bottomBar?)
            Positioned(left: 0, right: 0, bottom: MediaQuery.paddingOf(context).bottom, child: bottomBar),
        ],
      ),
    );
  }
}
