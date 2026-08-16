import 'dart:ui';

import 'package:flutter/material.dart';

import 'glass.dart';
import 'ledger_row.dart';
import 'tokens.dart';
import 'typography.dart';

/// One choice in a [showGlassMenu].
class GlassMenuItem<T> {
  const GlassMenuItem({required this.value, required this.title, this.subtitle, this.selected = false});

  final T value;
  final String title;
  final String? subtitle;
  final bool selected;
}

/// A menu hung under whatever was pressed. The screen behind it blurs rather than dims flat, so the
/// menu reads as the near layer of the same glass the chrome is made of.
Future<T?> showGlassMenu<T>(BuildContext context, List<GlassMenuItem<T>> items) {
  final anchor = context.findRenderObject()! as RenderBox;
  final overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final topLeft = anchor.localToGlobal(Offset.zero, ancestor: overlay);

  return Navigator.of(context).push(
    _GlassMenuRoute(items: items, anchor: topLeft + Offset(0, anchor.size.height + SpendableSpace.tight)),
  );
}

/// Tall enough for a year of months, short enough that it never reads as a screen.
const _maxHeight = 420.0;

class _GlassMenuRoute<T> extends PopupRoute<T> {
  _GlassMenuRoute({required this.items, required this.anchor});

  final List<GlassMenuItem<T>> items;
  final Offset anchor;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 220);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondary) {
    final colors = SpendableColors.of(context);
    final eased = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);

    return Stack(
      children: [
        // Outside the fade: a backdrop filter that fades in samples the screen on every frame of
        // the transition, which is what reads as the blur arriving late.
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: ColoredBox(color: colors.ground.withValues(alpha: 0.25)),
            ),
          ),
        ),
        Positioned(
          top: anchor.dy,
          left: anchor.dx,
          width: 280,
          // However many months there are, the menu stops short of the bottom of the screen and
          // scrolls the rest.
          height:
              (MediaQuery.sizeOf(context).height -
                      anchor.dy -
                      MediaQuery.paddingOf(context).bottom -
                      SpendableSpace.block)
                  .clamp(0.0, _maxHeight),
          child: FadeTransition(
            opacity: eased,
            child: ScaleTransition(
              scale: Tween(begin: 0.94, end: 1.0).animate(eased),
              alignment: Alignment.topLeft,
              // A route of its own has no Material above it, and text without one falls back to the
              // framework's yellow-underlined error style.
              child: Material(
                type: MaterialType.transparency,
                child: GlassPanel(
                  blur: SpendableChrome.menuBlur,
                  tint: colors.menu,
                  borderRadius: BorderRadius.circular(SpendableRadius.menu),
                  shadow: true,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return LedgerRow(
                        selected: item.selected,
                        ruleInset: SpendableSpace.step,
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpendableSpace.step,
                          vertical: SpendableSpace.tight + 1,
                        ),
                        onTap: () => Navigator.of(context).pop(item.value),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: SpendableType.title.copyWith(color: colors.primary)),
                            if (item.subtitle case final subtitle?)
                              Text(subtitle, style: SpendableType.subhead.copyWith(color: colors.secondary)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
