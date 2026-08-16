import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

/// The small uppercase label that names a figure without competing with it.
class Caption extends StatelessWidget {
  const Caption(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: SpendableType.caption.copyWith(color: color ?? SpendableColors.of(context).tertiary),
    );
  }
}
