import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_error.dart';
import '../budgets/budget_picker.dart';
import '../design/band_button.dart';
import '../design/caption.dart';
import '../design/glass.dart';
import '../design/glass_sheet.dart';
import '../design/glyph_icon.dart';
import '../design/ledger_row.dart';
import '../design/ledger_screen.dart';
import '../design/money_text.dart';
import '../design/nav_band.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import '../money.dart';
import 'transaction_detail.dart';
import 'transactions_controller.dart';
import 'transactions_providers.dart';

const _monthAbbreviations = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String shortDate(Date date) => '${_monthAbbreviations[date.month - 1]} ${date.day}, ${date.year}';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(transactionsProvider);
    final selection = ref.watch(selectionProvider);

    ref.listen(transactionsControllerProvider, (_, next) {
      // A validation error is already against the field it belongs to, so it needs no banner.
      if (next case AsyncError(:final error) when error is! ApiError || error.fieldErrors.isEmpty) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text('$error')));
      }
    });

    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;

        if (metrics.pixels >= metrics.maxScrollExtent - 400) {
          ref.read(transactionsProvider.notifier).loadMore();
        }

        return false;
      },
      child: LedgerScreen(
        onRefresh: () async => ref.invalidate(transactionsProvider),
        band: NavBand(
          title: 'Transactions',
          actions: [
            BandButton(
              key: const Key('open-filters'),
              icon: Glyph.funnel,
              onPressed: () => showGlassSheet<void>(context, (_) => const _Filters()),
            ),
          ],
        ),
        bottomBar: selection.isEmpty ? null : _BulkActions(selection: selection),
        slivers: switch (page) {
          AsyncData(value: final page) => _list(page, selection),
          AsyncError(:final error) => [_Message('$error')],
          _ => const [
            SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator())),
          ],
        },
      ),
    );
  }

  List<Widget> _list(TransactionPage page, Set<String> selection) {
    if (page.transactions.isEmpty) return const [_Message('Nothing to review.')];

    return [
      SliverList.builder(
        itemCount: page.transactions.length,
        itemBuilder: (_, index) => _Row(
          transaction: page.transactions[index],
          selected: selection.contains(page.transactions[index].id),
          selecting: selection.isNotEmpty,
        ),
      ),
    ];
  }
}

class _Row extends ConsumerWidget {
  const _Row({required this.transaction, required this.selected, required this.selecting});

  final Transaction transaction;
  final bool selected;
  final bool selecting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SpendableColors.of(context);
    final controller = ref.read(transactionsControllerProvider.notifier);
    final source = transaction.source_;

    // An excluded row and one already paired as a transfer are both out of the running.
    final dimmed = transaction.excluded || transaction.transferId != null;

    return Slidable(
      key: ValueKey(transaction.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.3,
        children: [
          _SwipeAction(
            label: transaction.reviewed ? 'Unreview' : 'Review',
            color: colors.positive,
            onPressed: () => controller.toggleReviewed(transaction),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.35,
        children: [
          _SwipeAction(label: 'Spend from', color: colors.accent, onPressed: () => _spendFrom(context, ref)),
        ],
      ),
      child: LedgerRow(
        key: Key('transaction-${transaction.id}'),
        selected: selected,
        dimmed: dimmed,
        onTap: () => showGlassSheet<void>(context, (_) => TransactionDetail(transaction: transaction)),
        onLongPress: () {
          HapticFeedback.selectionClick();
          ref.read(selectionProvider.notifier).toggle(transaction.id);
        },
        child: Row(
          children: [
            if (selecting) ...[
              GestureDetector(
                key: Key('select-${transaction.id}'),
                behavior: HitTestBehavior.opaque,
                onTap: () => ref.read(selectionProvider.notifier).toggle(transaction.id),
                child: Padding(
                  padding: const EdgeInsets.only(right: SpendableSpace.step),
                  child: GlyphIcon(
                    selected ? Glyph.checkCircleFill : Glyph.circle,
                    size: 22,
                    color: selected ? colors.accent : colors.tertiary,
                  ),
                ),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.name,
                    overflow: TextOverflow.ellipsis,
                    style: SpendableType.title.copyWith(color: colors.primary),
                  ),
                  Text(
                    [
                      shortDate(transaction.date),
                      if (source != null) '${source.accountName} ••••${source.accountNumber ?? ''}',
                      if (transaction.transferId != null) 'Transfer',
                    ].join(' · '),
                    style: SpendableType.subhead.copyWith(color: colors.secondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: SpendableSpace.step),
            MoneyText(money(transaction.amount), style: SpendableType.moneyRow, creditIsPositive: true),
            GestureDetector(
              key: Key('reviewed-${transaction.id}'),
              behavior: HitTestBehavior.opaque,
              onTap: () => controller.toggleReviewed(transaction),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: GlyphIcon(
                    transaction.reviewed ? Glyph.checkCircleFill : Glyph.circle,
                    size: 22,
                    color: transaction.reviewed ? colors.positive : colors.tertiary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _spendFrom(BuildContext context, WidgetRef ref) async {
    final chosen = await pickBudget(context, ref);

    if (chosen == null) return;

    await ref.read(transactionsControllerProvider.notifier).bulk(ids: {transaction.id}, budgetId: chosen.id);
  }
}

class _SwipeAction extends StatelessWidget {
  const _SwipeAction({required this.label, required this.color, required this.onPressed});

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          Slidable.of(context)?.close();
          onPressed();
        },
        child: ColoredBox(
          color: color,
          child: Center(child: Caption(label, color: SpendableColors.of(context).ground)),
        ),
      ),
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filtersProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: SpendableSpace.tight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpendableSpace.gutter),
              child: TextField(
                key: const Key('transaction-search'),
                decoration: const InputDecoration(labelText: 'Search name or note'),
                onSubmitted: ref.read(filtersProvider.notifier).search,
              ),
            ),
            const SizedBox(height: SpendableSpace.step),
            _Toggle(
              key: const Key('filter-reviewed'),
              label: 'Show reviewed transactions',
              value: filters.showReviewed,
              onChanged: ref.read(filtersProvider.notifier).toggleReviewed,
            ),
            _Toggle(
              key: const Key('filter-excluded'),
              label: 'Show excluded transactions',
              value: filters.showExcluded,
              onChanged: ref.read(filtersProvider.notifier).toggleExcluded,
            ),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);

    return LedgerRow(
      onTap: onChanged,
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: SpendableType.body.copyWith(color: colors.primary)),
          ),
          Switch.adaptive(value: value, onChanged: (_) => onChanged()),
        ],
      ),
    );
  }
}

/// What can be done to a selection, on the same glass as the tab bar it sits above.
class _BulkActions extends ConsumerWidget {
  const _BulkActions({required this.selection});

  final Set<String> selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SpendableColors.of(context);
    final controller = ref.read(transactionsControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpendableChrome.inset,
        0,
        SpendableChrome.inset,
        SpendableSpace.tight,
      ),
      child: GlassPanel(
        blur: SpendableChrome.tabBarBlur,
        tint: colors.chrome,
        borderRadius: BorderRadius.circular(SpendableRadius.capsule),
        shadow: true,
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              GestureDetector(
                key: const Key('bulk-clear'),
                behavior: HitTestBehavior.opaque,
                onTap: () => ref.read(selectionProvider.notifier).clear(),
                child: SizedBox(
                  width: 50,
                  child: Center(child: GlyphIcon(Glyph.x, size: 18, color: colors.secondary)),
                ),
              ),
              Text('${selection.length}', style: SpendableType.moneyInline.copyWith(color: colors.primary)),
              // The actions do not fit across a phone, and one of them appearing only for a pair
              // means the width changes as the selection does.
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    children: [
                      _Action(
                        actionKey: const Key('bulk-review'),
                        label: 'Review',
                        onPressed: () => controller.bulk(ids: selection, reviewed: true),
                      ),
                      _Action(
                        actionKey: const Key('bulk-exclude'),
                        label: 'Exclude',
                        onPressed: () => controller.bulk(ids: selection, excluded: true),
                      ),
                      _Action(
                        actionKey: const Key('bulk-spend-from'),
                        label: 'Spend from',
                        onPressed: () => _pick(context, ref),
                      ),
                      // A transfer is one transaction leaving an account and one arriving in another.
                      if (selection.length == 2)
                        _Action(
                          actionKey: const Key('bulk-transfer'),
                          label: 'Transfer',
                          onPressed: () => controller.markAsTransfer(selection),
                        ),
                      _Action(
                        actionKey: const Key('bulk-delete'),
                        label: 'Delete',
                        color: colors.negative,
                        onPressed: () => controller.deleteAll(selection),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final chosen = await pickBudget(context, ref);

    if (chosen == null) return;

    await ref.read(transactionsControllerProvider.notifier).bulk(ids: selection, budgetId: chosen.id);
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.actionKey, required this.label, required this.onPressed, this.color});

  final Key actionKey;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);

    return Row(
      children: [
        Container(width: 1, height: 22, color: colors.separator),
        GestureDetector(
          key: actionKey,
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: SpendableSpace.step),
            alignment: Alignment.center,
            child: Text(label, style: SpendableType.body.copyWith(color: color ?? colors.accent)),
          ),
        ),
      ],
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
