import 'package:flutter/material.dart';

import 'caption.dart';
import 'tokens.dart';

/// Names what follows, with the rule running out from the caption to the edge. It is how the screen
/// changes subject without a card or a heading.
class SectionRule extends StatelessWidget {
  const SectionRule(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpendableSpace.gutter,
        SpendableSpace.block,
        SpendableSpace.gutter,
        SpendableSpace.tight,
      ),
      child: Row(
        children: [
          Caption(title),
          const SizedBox(width: SpendableSpace.step),
          Expanded(child: Container(height: 1, color: colors.separator)),
        ],
      ),
    );
  }
}
