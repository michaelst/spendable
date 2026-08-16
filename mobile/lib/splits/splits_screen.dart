import 'package:flutter/material.dart' hide Split;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_error.dart';
import '../design/band_button.dart';
import '../design/glass_sheet.dart';
import '../design/glyph_icon.dart';
import '../design/ledger_row.dart';
import '../design/ledger_screen.dart';
import '../design/money_text.dart';
import '../design/nav_band.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import '../money.dart';
import 'split_form.dart';
import 'splits_controller.dart';
import 'splits_providers.dart';

class SplitsScreen extends ConsumerWidget {
  const SplitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splits = ref.watch(splitsProvider);
    final selection = ref.watch(splitSelectionProvider);

    ref.listen(splitsControllerProvider, (_, next) {
      // A validation error is already against the field it belongs to, so it needs no banner.
      if (next case AsyncError(:final error) when error is! ApiError || error.fieldErrors.isEmpty) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text('$error')));
      }
    });

    return LedgerScreen(
      onRefresh: () async => ref.invalidate(splitsProvider),
      band: NavBand(
        title: 'Splits',
        actions: [
          if (selection.isNotEmpty)
            BandButton(
              key: const Key('archive-selected'),
              label: 'Archive (${selection.length})',
              onPressed: () => ref.read(splitsControllerProvider.notifier).archive(selection),
            ),
          BandButton(key: const Key('new-split'), icon: Glyph.plus, onPressed: () => openSplitForm(context)),
        ],
      ),
      slivers: switch (splits) {
        AsyncData(value: final splits) when splits.isEmpty => const [_Message('No splits yet.')],
        AsyncData(value: final splits) => [
          SliverList.builder(
            itemCount: splits.length,
            itemBuilder: (_, index) => _Row(
              split: splits[index],
              selected: selection.contains(splits[index].id),
              selecting: selection.isNotEmpty,
            ),
          ),
        ],
        AsyncError(:final error) => [_Message('$error')],
        _ => const [
          SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator())),
        ],
      },
    );
  }
}

Future<void> openSplitForm(BuildContext context, {Split? split}) =>
    showGlassSheet<void>(context, (_) => SplitForm(split: split));

class _Row extends ConsumerWidget {
  const _Row({required this.split, required this.selected, required this.selecting});

  final Split split;
  final bool selected;
  final bool selecting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SpendableColors.of(context);
    final total = split.splitLines.fold(money('0'), (sum, line) => sum + money(line.amount));

    return LedgerRow(
      key: Key('split-${split.id}'),
      selected: selected,
      onTap: () => openSplitForm(context, split: split),
      onLongPress: () {
        HapticFeedback.selectionClick();
        ref.read(splitSelectionProvider.notifier).toggle(split.id);
      },
      child: Row(
        children: [
          if (selecting)
            GestureDetector(
              key: Key('select-split-${split.id}'),
              behavior: HitTestBehavior.opaque,
              onTap: () => ref.read(splitSelectionProvider.notifier).toggle(split.id),
              child: Padding(
                padding: const EdgeInsets.only(right: SpendableSpace.step),
                child: GlyphIcon(
                  selected ? Glyph.checkCircleFill : Glyph.circle,
                  size: 22,
                  color: selected ? colors.accent : colors.tertiary,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(split.name, style: SpendableType.title.copyWith(color: colors.primary)),
                Text(
                  '${split.splitLines.length} ${split.splitLines.length == 1 ? 'line' : 'lines'}',
                  style: SpendableType.subhead.copyWith(color: colors.secondary),
                ),
              ],
            ),
          ),
          MoneyText(total, style: SpendableType.moneyRow),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(SpendableSpace.block),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: SpendableType.body.copyWith(color: SpendableColors.of(context).secondary),
          ),
        ),
      ),
    );
  }
}
