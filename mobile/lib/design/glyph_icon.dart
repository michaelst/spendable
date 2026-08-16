import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'tokens.dart';

/// The Phosphor glyphs, vendored under assets/icons from the same set the web app draws from so the
/// two products share an icon language.
enum Glyph {
  appleLogo,
  bank,
  bankFill,
  caretDown,
  caretLeft,
  caretRight,
  checkCircleFill,
  circle,
  copy,
  copyFill,
  creditCard,
  creditCardFill,
  funnel,
  minusCircle,
  money,
  moneyFill,
  plus,
  trash,
  user,
  wallet,
  x;

  String get asset =>
      'assets/icons/${name.replaceAllMapped(RegExp('[A-Z]'), (match) => '-${match[0]!.toLowerCase()}')}.svg';
}

class GlyphIcon extends StatelessWidget {
  const GlyphIcon(this.glyph, {super.key, this.size = 22, this.color});

  final Glyph glyph;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      glyph.asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color ?? SpendableColors.of(context).primary, BlendMode.srcIn),
    );
  }
}
