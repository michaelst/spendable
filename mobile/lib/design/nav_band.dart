import 'package:flutter/material.dart';

import 'glass.dart';
import 'tokens.dart';
import 'typography.dart';

/// The band across the top of a screen. It is clear while the large title is showing and glass once
/// the list has scrolled under it, which is the only moment the chrome needs to separate itself.
class NavBand extends StatelessWidget {
  const NavBand({super.key, required this.title, this.largeTitle, this.leading, this.actions = const []});

  final String title;

  /// Replaces the plain large title, for a screen whose title is something to press.
  final Widget? largeTitle;
  final Widget? leading;
  final List<Widget> actions;

  static const _largeTitleExtent = 52.0;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _NavBandDelegate(
        title: title,
        largeTitle: largeTitle,
        leading: leading,
        actions: actions,
        topPadding: MediaQuery.paddingOf(context).top,
      ),
    );
  }
}

class _NavBandDelegate extends SliverPersistentHeaderDelegate {
  _NavBandDelegate({
    required this.title,
    required this.largeTitle,
    required this.leading,
    required this.actions,
    required this.topPadding,
  });

  final String title;
  final Widget? largeTitle;
  final Widget? leading;
  final List<Widget> actions;
  final double topPadding;

  @override
  double get minExtent => topPadding + SpendableChrome.barHeight;

  @override
  double get maxExtent => minExtent + NavBand._largeTitleExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final colors = SpendableColors.of(context);
    final collapsed = (shrinkOffset / NavBand._largeTitleExtent).clamp(0.0, 1.0);

    // The compact title only starts arriving once the large one is most of the way gone, so the two
    // are never both legible at once.
    final compact = ((collapsed - 0.6) / 0.4).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Skipped rather than faded out at the top of the list, so nothing is blurred behind a
        // pane that is not there yet.
        if (collapsed > 0)
          Opacity(
            opacity: collapsed,
            child: GlassPanel(
              blur: SpendableChrome.bandBlur,
              tint: colors.band,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(height: 0.5, color: colors.separator),
              ),
            ),
          ),
        Positioned(
          top: topPadding,
          left: SpendableSpace.hair,
          right: SpendableSpace.hair,
          height: SpendableChrome.barHeight,
          child: Row(
            children: [
              ?leading,
              Expanded(
                child: compact == 0
                    ? const SizedBox.shrink()
                    : Opacity(
                        opacity: compact,
                        // Left, where the large title it replaces was, so the title does not travel
                        // across the band as the list scrolls under it.
                        child: Padding(
                          padding: const EdgeInsets.only(left: SpendableSpace.tight),
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: SpendableType.title.copyWith(color: colors.primary),
                          ),
                        ),
                      ),
              ),
              ...actions,
            ],
          ),
        ),
        Positioned(
          left: SpendableSpace.gutter,
          right: SpendableSpace.gutter,
          bottom: SpendableSpace.tight,
          child: Opacity(
            opacity: 1 - collapsed,
            child:
                largeTitle ??
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(title, style: SpendableType.largeTitle.copyWith(color: colors.primary)),
                ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(_NavBandDelegate old) =>
      title != old.title ||
      topPadding != old.topPadding ||
      largeTitle != old.largeTitle ||
      leading != old.leading ||
      actions != old.actions;
}
