import 'package:flutter/material.dart';

import 'glyph_icon.dart';
import 'tokens.dart';
import 'typography.dart';

/// Reads like the fields beside it, but opens a sheet instead of the keyboard. A dropdown would be
/// the one Material shape left in a screen that has none.
class PickerField extends StatelessWidget {
  const PickerField({super.key, required this.label, required this.value, required this.onTap, this.error});

  final String label;

  /// Null reads as the placeholder, in the same grey as the label.
  final String? value;
  final VoidCallback onTap;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: SpendableSpace.tight),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? label,
                    overflow: TextOverflow.ellipsis,
                    style: SpendableType.body.copyWith(
                      color: value == null ? colors.secondary : colors.primary,
                    ),
                  ),
                ),
                GlyphIcon(Glyph.caretDown, size: 14, color: colors.tertiary),
              ],
            ),
          ),
          Container(height: 1, color: error == null ? colors.separator : colors.negative),
          if (error case final error?)
            Padding(
              padding: const EdgeInsets.only(top: SpendableSpace.hair),
              child: Text(error, style: SpendableType.subhead.copyWith(color: colors.negative)),
            ),
        ],
      ),
    );
  }
}
