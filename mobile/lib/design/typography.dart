import 'package:flutter/material.dart';

/// The ramp from the token sheet. Letter spacing there is in em, and is multiplied out here
/// because Flutter measures it in logical pixels.
///
/// No family is named, so iOS resolves the system face - SF Pro - rather than shipping a copy of it.
abstract final class SpendableType {
  /// Money always sets in tabular figures, so a decimal point stacks down a column.
  static const _tabular = [FontFeature.tabularFigures()];

  static const largeTitle = TextStyle(fontSize: 33, fontWeight: FontWeight.w600, letterSpacing: -0.73);
  static const title = TextStyle(fontSize: 17, fontWeight: FontWeight.w500, letterSpacing: -0.17);
  static const body = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: -0.15);
  static const subhead = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

  /// Always set through [Caption], which is what uppercases it.
  static const caption = TextStyle(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.17);

  static const moneyHero = TextStyle(
    fontSize: 37,
    fontWeight: FontWeight.w500,
    letterSpacing: -1.11,
    fontFeatures: _tabular,
  );

  static const moneyRow = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.53,
    fontFeatures: _tabular,
  );

  /// A transaction's amount, a step down from a budget's because it sits beside a name and a date
  /// rather than heading a card of its own.
  static const moneyListRow = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.46,
    fontFeatures: _tabular,
  );

  /// A figure that has to line up in a column but is not the row's headline.
  static const moneyInline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.15,
    fontFeatures: _tabular,
  );
}
