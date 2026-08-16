import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';
import 'typography.dart';

/// Filled is the one thing a sheet is for; plain is an alternative offered rather than urged;
/// destructive is a word in red, so archiving never competes with saving.
enum ButtonVariant { filled, plain, destructive }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);
    final enabled = onPressed != null;

    final color = switch (variant) {
      ButtonVariant.filled => colors.ground,
      ButtonVariant.plain => colors.accent,
      ButtonVariant.destructive => colors.negative,
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              onPressed!();
            }
          : null,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: switch (variant) {
          ButtonVariant.filled => BoxDecoration(
            color: enabled ? colors.accent : colors.tertiary,
            borderRadius: BorderRadius.circular(SpendableRadius.capsule),
          ),
          ButtonVariant.plain => BoxDecoration(
            border: Border.all(color: colors.separator),
            borderRadius: BorderRadius.circular(SpendableRadius.capsule),
          ),
          ButtonVariant.destructive => null,
        },
        child: Text(
          label,
          style: SpendableType.title.copyWith(
            color: enabled ? color : colors.tertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
