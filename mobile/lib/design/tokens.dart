import 'package:flutter/material.dart';

/// The palette from the token sheet: content is flat and hairline-ruled, so there is no raised
/// surface colour - only the ground, the rules drawn on it, and the glass every control is cut from.
@immutable
class SpendableColors {
  const SpendableColors._({
    required this.ground,
    required this.separator,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.accent,
    required this.positive,
    required this.negative,
    required this.trackingPill,
    required this.chrome,
    required this.band,
    required this.menu,
    required this.litEdge,
    required this.ring,
    required this.chromeShadow,
  });

  /// Brightness alone decides, so a screen mounted without the app's theme still reads right.
  static SpendableColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  static const light = SpendableColors._(
    ground: Color(0xFFF4F5F8),
    separator: Color(0x2118181B),
    primary: Color(0xFF18181B),
    secondary: Color(0xFF5A5A63),
    tertiary: Color(0xFFA0A0A9),
    accent: Color(0xFF2E77C7),
    positive: Color(0xFF146C43),
    negative: Color(0xFFB4123B),
    trackingPill: Color(0xFFA0A0A9),
    chrome: Color(0xB8FFFFFF),
    band: Color(0xB8FFFFFF),
    menu: Color(0xCCFFFFFF),
    litEdge: Color(0xF2FFFFFF),
    ring: Color(0x8CFFFFFF),
    chromeShadow: Color(0x29141C2D),
  );

  static const dark = SpendableColors._(
    ground: Color(0xFF111827),
    separator: Color(0x1FFFFFFF),
    primary: Color(0xFFFFFFFF),
    secondary: Color(0xFF9CA3AF),
    tertiary: Color(0xFF6B7280),
    accent: Color(0xFF65B0ED),
    positive: Color(0xFF45DE8E),
    negative: Color(0xFFF97066),
    trackingPill: Color(0xFF9CA3AF),
    chrome: Color(0x9E232C3E),
    band: Color(0x94111827),
    menu: Color(0xBD202838),
    litEdge: Color(0x29FFFFFF),
    ring: Color(0x1AFFFFFF),
    chromeShadow: Color(0x80000000),
  );

  final Color ground;
  final Color separator;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color accent;
  final Color positive;
  final Color negative;

  /// Envelope and Goal pills borrow accent and positive; only Tracking has its own.
  final Color trackingPill;

  final Color chrome;
  final Color band;
  final Color menu;
  final Color litEdge;
  final Color ring;
  final Color chromeShadow;

  /// Money is read by sign before it is read as a number.
  Color forAmount(num sign) => sign < 0 ? negative : primary;
}

/// The content scale. Chrome insets itself instead, at [SpendableChrome].
abstract final class SpendableSpace {
  static const hair = 4.0;
  static const tight = 7.0;
  static const step = 13.0;
  static const gutter = 17.0;
  static const block = 24.0;
}

/// Every row and rail is square; only glass is rounded.
abstract final class SpendableRadius {
  static const row = 0.0;
  static const tabBar = 31.0;
  static const capsule = 25.0;
  static const menu = 16.0;
}

/// The floating tab bar's geometry, which every scroll view has to clear.
abstract final class SpendableChrome {
  static const inset = 14.0;

  /// Measured from the bottom of the screen rather than from the safe area: a floating bar sits
  /// over the home indicator's margin the way iOS does, not stacked on top of it.
  static const bottomInset = 24.0;
  static const tabBarHeight = 62.0;
  static const barHeight = 44.0;
  static const bandBlur = 26.0;
  static const tabBarBlur = 28.0;
  static const menuBlur = 30.0;

  /// What the tab bar takes out of the bottom of the screen, safe area included.
  static const tabBarExtent = tabBarHeight + bottomInset;
}
