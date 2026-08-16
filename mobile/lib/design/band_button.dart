import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glyph_icon.dart';
import 'tokens.dart';
import 'typography.dart';

/// An action in the nav band: an icon or a word, in accent, over a 44pt target and nothing else.
class BandButton extends StatelessWidget {
  const BandButton({super.key, this.icon, this.label, required this.onPressed})
    : assert(icon != null || label != null, 'a band button needs an icon or a label');

  final Glyph? icon;
  final String? label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);
    final color = onPressed == null ? colors.tertiary : colors.accent;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onPressed!();
            },
      child: Container(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        padding: EdgeInsets.symmetric(horizontal: label == null ? 0 : SpendableSpace.tight),
        alignment: Alignment.center,
        child: icon != null
            ? GlyphIcon(icon!, color: color)
            : Text(label!, style: SpendableType.title.copyWith(color: color)),
      ),
    );
  }
}
