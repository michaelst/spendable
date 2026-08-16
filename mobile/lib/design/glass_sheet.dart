import 'package:flutter/material.dart';

import 'glass.dart';
import 'tokens.dart';

/// Every sheet in the app: glass over a dimmed screen, a grabber, and nothing between it and the
/// keyboard.
Future<T?> showGlassSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    // Without this a long sheet runs up under the status bar, where its own grabber is the part
    // that ends up unreachable and there is nothing left to close it with.
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x59000000),
    builder: (context) => _GlassSheet(child: builder(context)),
  );
}

class _GlassSheet extends StatelessWidget {
  const _GlassSheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);

    return GlassPanel(
      blur: SpendableChrome.menuBlur,
      tint: colors.menu,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(SpendableRadius.menu)),
      shadow: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: SpendableSpace.tight, bottom: SpendableSpace.hair),
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: colors.tertiary.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          Flexible(child: child),
        ],
      ),
    );
  }
}
