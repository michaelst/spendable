import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../money.dart';
import 'tokens.dart';

/// An amount, set in tabular figures and coloured by its sign. Positive money is only ever green
/// where being in the black is the point; everywhere else it reads as ordinary text.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.amount, {
    super.key,
    required this.style,
    this.creditIsPositive = false,
    this.neutral = false,
  });

  final Decimal amount;
  final TextStyle style;
  final bool creditIsPositive;

  /// Set where a list of amounts is the whole screen and colouring every one of them by sign says
  /// nothing - the sign is already in the figure.
  final bool neutral;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);

    final color = switch (amount.sign) {
      _ when neutral => colors.primary,
      < 0 => colors.negative,
      _ => creditIsPositive ? colors.positive : colors.primary,
    };

    return Text(formatCurrency(amount), style: style.copyWith(color: color));
  }
}
