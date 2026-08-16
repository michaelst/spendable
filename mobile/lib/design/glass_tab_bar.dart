import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass.dart';
import 'glyph_icon.dart';
import 'tokens.dart';
import 'typography.dart';

/// How far the selection capsule sits inside its slot.
const _capsuleInset = 6.0;

/// One destination in [GlassTabBar]. The selected tab fills its glyph, which is what iOS does to
/// say a tab is the one you are in without relying on colour alone.
class TabDestination {
  const TabDestination({required this.key, required this.icon, required this.fill, required this.label});

  final Key key;
  final Glyph icon;
  final Glyph fill;
  final String label;
}

/// The tab bar floats clear of the bottom edge as a glass capsule, and the list scrolls under it
/// rather than stopping above it.
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<TabDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        left: SpendableChrome.inset,
        right: SpendableChrome.inset,
        bottom: SpendableChrome.bottomInset,
      ),
      child: GlassPanel(
        blur: SpendableChrome.tabBarBlur,
        tint: colors.chrome,
        borderRadius: BorderRadius.circular(SpendableRadius.tabBar),
        shadow: true,
        child: SizedBox(
          height: SpendableChrome.tabBarHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final slot = constraints.maxWidth / destinations.length;

              return Stack(
                children: [
                  // The capsule slides rather than reappearing, so the eye follows the selection
                  // across instead of having to find it again.
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    left: slot * selectedIndex + _capsuleInset,
                    width: slot - _capsuleInset * 2,
                    top: SpendableSpace.tight,
                    bottom: SpendableSpace.tight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(SpendableRadius.capsule),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (final (index, destination) in destinations.indexed)
                        Expanded(
                          child: _Tab(
                            destination: destination,
                            selected: index == selectedIndex,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              onSelected(index);
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.destination, required this.selected, required this.onTap});

  final TabDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);
    final color = selected ? colors.accent : colors.secondary;

    return GestureDetector(
      key: destination.key,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlyphIcon(selected ? destination.fill : destination.icon, size: 23, color: color),
          Text(
            destination.label,
            style: SpendableType.caption.copyWith(
              fontSize: 10,
              letterSpacing: 0,
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
