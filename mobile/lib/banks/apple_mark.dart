import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Apple's own mark, taken from the system font at U+F8FF rather than drawn again from a shape
/// library. It is the real one, and it is not artwork the app has to ship or keep in step.
class AppleMark extends StatelessWidget {
  const AppleMark({super.key, this.size = 22, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      '',
      // The mark sits high in its em box, so it reads a size smaller than a glyph set beside it.
      style: TextStyle(fontSize: size, color: color ?? SpendableColors.of(context).primary, height: 1.2),
    );
  }
}
