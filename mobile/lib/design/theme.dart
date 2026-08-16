import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

/// The app is drawn from [SpendableColors] and [SpendableType] directly; this only teaches the
/// Material widgets that remain - fields, switches, pickers - to sit inside that.
ThemeData spendableTheme(Brightness brightness) {
  final colors = brightness == Brightness.dark ? SpendableColors.dark : SpendableColors.light;
  final base = ThemeData(brightness: brightness, useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: colors.ground,
    canvasColor: colors.ground,
    colorScheme: base.colorScheme.copyWith(
      surface: colors.ground,
      primary: colors.accent,
      error: colors.negative,
      onSurface: colors.primary,
    ),
    // Cupertino throughout, so a push slides and a swipe from the edge goes back.
    platform: TargetPlatform.iOS,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.iOS: CupertinoPageTransitionsBuilder()},
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textTheme: base.textTheme.apply(bodyColor: colors.primary, displayColor: colors.primary),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colors.accent,
      selectionColor: colors.accent.withValues(alpha: 0.3),
      selectionHandleColor: colors.accent,
    ),
    // Fields are ruled like the rest of the content: a hairline under, nothing around.
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: SpendableSpace.tight),
      labelStyle: SpendableType.body.copyWith(color: colors.secondary),
      floatingLabelStyle: SpendableType.subhead.copyWith(color: colors.secondary),
      errorStyle: SpendableType.subhead.copyWith(color: colors.negative),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.separator)),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.accent)),
      errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.negative)),
      focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.negative)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colors.primary,
      contentTextStyle: SpendableType.body.copyWith(color: colors.ground),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.accent),
    dividerTheme: DividerThemeData(color: colors.separator, space: 1, thickness: 1),
  );
}
