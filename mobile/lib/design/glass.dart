import 'package:flutter/material.dart';

import 'tokens.dart';

/// A pane of glass: what is behind it blurred and saturated, a tint over that, a lit top edge and a
/// hairline ring around it. Every control in the app is cut from one of these; content never is.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    required this.blur,
    required this.tint,
    this.borderRadius = BorderRadius.zero,
    this.shadow = false,
    this.litEdge = true,
  });

  final Widget child;
  final double blur;
  final Color tint;
  final BorderRadius borderRadius;

  /// Only glass that floats free of an edge casts one.
  final bool shadow;
  final bool litEdge;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadow
            ? [BoxShadow(color: colors.chromeShadow, blurRadius: 34, offset: const Offset(0, 14))]
            : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        // Grouped so the several panes on a screen sample the backdrop once between them, and
        // bounded so the kernel only reads what is behind the pane. An unbounded blur pulls in
        // transparent black from outside its edges, which is what makes a plain BackdropFilter
        // read as a washed-out rectangle rather than as glass.
        child: BackdropFilter.grouped(
          filterConfig: ImageFilterConfig.compose(
            outer: const ImageFilterConfig(ColorFilter.matrix(_saturate)),
            inner: ImageFilterConfig.blur(sigmaX: blur, sigmaY: blur, bounded: true),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tint,
              borderRadius: borderRadius,
              border: Border.all(color: colors.ring, width: 0.5),
            ),
            child: Stack(
              children: [
                child,
                // The highlight along the top, which is what makes the pane read as lit rather than
                // as a flat translucent rectangle. Flutter has no inset shadow.
                //
                // It fades out towards the ends rather than running the full width: glass catches
                // the light across its crown, and an even line reads as a drawn border instead.
                if (litEdge)
                  Positioned(
                    top: 0,
                    left: borderRadius.topLeft.x,
                    right: borderRadius.topRight.x,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, colors.litEdge, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// saturate(180%), in the matrix form `ColorFilter` takes. The luminance weights are the ones the
/// CSS filter is defined with.
const _saturate = <double>[
  1.6296, -0.5720, -0.0576, 0, 0, //
  -0.1704, 1.2280, -0.0576, 0, 0,
  -0.1704, -0.5720, 1.7424, 0, 0,
  0, 0, 0, 1, 0,
];
