import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_error.dart';
import '../money.dart';
import '../theme.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            key: const Key('open-filters'),
            icon: const Icon(Icons.filter_list),
            onPressed: () => showModalBottomSheet<void>(context: context, builder: (_) => const _Filters()),
          ),
        ],
      ),
      bottomNavigationBar: selection.isEmpty ? null : _BulkActions(selection: selection),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(transactionsProvider),
        child: switch (page) {
          AsyncData(value: final page) => _List(page: page, selection: selection),
          AsyncError(:final error) => _Message('$error'),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _List extends ConsumerWidget {
  const _List({required this.page, required this.selection});

  final TransactionPage page;
  final Set<String> selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (page.transactions.isEmpty) return const _Message('Nothing to review.');

    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;

        if (metrics.pixels >= metrics.maxScrollExtent - 400) {
          ref.read(transactionsProvider.notifier).loadMore();
        }

        return false;
      },
      child: ListView.separated(
        itemCount: page.transactions.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final transaction = page.transactions[index];

          return _Row(transaction: transaction, selected: selection.contains(transaction.id));
        },
      ),
    );
  }
}

class _Row extends ConsumerWidget {
  const _Row({required this.transaction, required this.selected});

  final Transaction transaction;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(transactionsControllerProvider.notifier);
    final source = transaction.source_;

    // An excluded row and one already paired as a transfer are both out of the running.
    final dimmed = transaction.excluded || transaction.transferId != null;

    return Opacity(
      opacity: dimmed ? 0.4 : 1,
      child: ListTile(
        key: Key('transaction-${transaction.id}'),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => TransactionDetail(transaction: transaction),
        ),
        onLongPress: () => ref.read(selectionProvider.notifier).toggle(transaction.id),
        leading: Checkbox(
          key: Key('select-${transaction.id}'),
          value: selected,
          onChanged: (_) => ref.read(selectionProvider.notifier).toggle(transaction.id),
        ),
        title: Text(transaction.name, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [
            shortDate(transaction.date),
            if (source != null) '${source.accountName} ••••${source.accountNumber ?? ''}',
            if (transaction.transferId != null) 'Transfer',
          ].join('  ·  '),
          style: const TextStyle(color: SpendableColors.muted, fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatCurrency(money(transaction.amount)),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            IconButton(
              key: Key('reviewed-${transaction.id}'),
              tooltip: transaction.reviewed ? 'Mark unreviewed' : 'Mark reviewed',
              icon: Icon(
                transaction.reviewed ? Icons.check_circle : Icons.circle_outlined,
                color: transaction.reviewed ? SpendableColors.positive : SpendableColors.muted,
              ),
              onPressed: () => controller.toggleReviewed(transaction),
            ),
          ],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              key: const Key('transaction-search'),
              decoration: const InputDecoration(labelText: 'Search name or note'),
              onSubmitted: ref.read(filtersProvider.notifier).search,
            ),
          ),
          SwitchListTile(
            key: const Key('filter-reviewed'),
            title: const Text('Show reviewed transactions'),
            value: filters.showReviewed,
            onChanged: (_) => ref.read(filtersProvider.notifier).toggleReviewed(),
          ),
          SwitchListTile(
            key: const Key('filter-excluded'),
            title: const Text('Show excluded transactions'),
            value: filters.showExcluded,
            onChanged: (_) => ref.read(filtersProvider.notifier).toggleExcluded(),
          ),
        ],
      ),
    );
  }
}

class _BulkActions extends ConsumerWidget {
  const _BulkActions({required this.selection});

  final Set<String> selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(transactionsControllerProvider.notifier);

    return BottomAppBar(
      color: SpendableColors.surface,
      child: Row(
        children: [
          IconButton(
            key: const Key('bulk-clear'),
            icon: const Icon(Icons.close),
            onPressed: () => ref.read(selectionProvider.notifier).clear(),
          ),
          Text('${selection.length}'),
          // The actions do not fit across a phone, and one of them appearing only for a pair
          // means the width changes as the selection does.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                children: [
                  TextButton(
                    key: const Key('bulk-review'),
                    onPressed: () => controller.bulk(ids: selection, reviewed: true),
                    child: const Text('Review'),
                  ),
                  TextButton(
                    key: const Key('bulk-exclude'),
                    onPressed: () => controller.bulk(ids: selection, excluded: true),
                    child: const Text('Exclude'),
                  ),
                  TextButton(
                    key: const Key('bulk-spend-from'),
                    onPressed: () => _pickBudget(context, ref),
                    child: const Text('Spend from'),
                  ),
                  // A transfer is one transaction leaving an account and one arriving in another.
                  if (selection.length == 2)
                    TextButton(
                      key: const Key('bulk-transfer'),
                      onPressed: () => controller.markAsTransfer(selection),
                      child: const Text('Transfer'),
                    ),
                  IconButton(
                    key: const Key('bulk-delete'),
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => controller.deleteAll(selection),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickBudget(BuildContext context, WidgetRef ref) async {
    final budgets = ref.read(budgetOptionsProvider).value ?? const <Budget>[];

    final chosen = await showModalBottomSheet<Budget>(
      context: context,
      builder: (_) => ListView(
        children: [
          for (final budget in budgets)
            ListTile(
              key: Key('budget-${budget.id}'),
              title: Text(budget.name),
              onTap: () => Navigator.of(context).pop(budget),
            ),
        ],
      ),
    );

    if (chosen == null) return;

    await ref.read(transactionsControllerProvider.notifier).bulk(ids: selection, budgetId: chosen.id);
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Text(text, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
