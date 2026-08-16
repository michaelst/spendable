import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

/// What a sheet is called, with the action that closes it kept beside the title rather than below
/// the fold on a phone.
class SheetHeader extends StatelessWidget {
  const SheetHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(title, style: SpendableType.title.copyWith(color: colors.primary)),
        ),
        ?action,
      ],
    );
  }
}
