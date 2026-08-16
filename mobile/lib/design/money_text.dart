import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../money.dart';
import 'tokens.dart';

/// An amount, set in tabular figures and coloured by its sign. Positive money is only ever green
/// where being in the black is the point; everywhere else it reads as ordinary text.
class MoneyText extends StatelessWidget {
  const MoneyText(this.amount, {super.key, required this.style, this.creditIsPositive = false});

  final Decimal amount;
  final TextStyle style;
  final bool creditIsPositive;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);

    final color = switch (amount.sign) {
      < 0 => colors.negative,
      _ => creditIsPositive ? colors.positive : colors.primary,
    };

    return Text(formatCurrency(amount), style: style.copyWith(color: color));
  }
}
