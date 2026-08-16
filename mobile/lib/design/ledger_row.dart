import 'package:flutter/material.dart';

import 'tokens.dart';

/// A row in the ledger. It has no card, no corner and no fill of its own - what separates it from
/// the next row is the hairline it closes with, and progress is that same hairline thickened to 2px
/// and coloured for as far as it has got.
class LedgerRow extends StatefulWidget {
  const LedgerRow({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.dimmed = false,
    this.progress,
    this.progressColor,
    this.ruleInset = SpendableSpace.gutter,
    this.padding = const EdgeInsets.symmetric(
      horizontal: SpendableSpace.gutter,
      vertical: SpendableSpace.step,
    ),
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;

  /// An excluded transaction, or one already paired as a transfer: still there, out of the running.
  final bool dimmed;

  /// 0 to 1 of the row's full width. Null leaves the plain hairline.
  final double? progress;
  final Color? progressColor;

  /// The rule runs full bleed under a budget and inset under a list row, matching where the row's
  /// own content starts.
  final double ruleInset;
  final EdgeInsets padding;

  @override
  State<LedgerRow> createState() => _LedgerRowState();
}

class _LedgerRowState extends State<LedgerRow> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);
    final tappable = widget.onTap != null || widget.onLongPress != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: tappable ? (_) => setState(() => _pressed = true) : null,
      onTapUp: tappable ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: tappable ? () => setState(() => _pressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: switch ((widget.selected, _pressed)) {
          (true, _) => colors.accent.withValues(alpha: 0.12),
          (_, true) => colors.primary.withValues(alpha: 0.05),
          _ => Colors.transparent,
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: widget.padding,
              child: Opacity(opacity: widget.dimmed ? 0.4 : 1, child: widget.child),
            ),
            _Rule(inset: widget.ruleInset, progress: widget.progress, color: widget.progressColor),
          ],
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.inset, required this.progress, required this.color});

  final double inset;
  final double? progress;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);

    return SizedBox(
      height: 2,
      child: Stack(
        children: [
          Positioned(
            left: inset,
            right: 0,
            bottom: 0,
            height: 1,
            child: ColoredBox(color: colors.separator),
          ),
          if (progress case final progress?)
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0, 1),
                  heightFactor: 1,
                  child: ColoredBox(color: color ?? colors.accent),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
