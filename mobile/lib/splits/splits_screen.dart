import 'package:flutter/material.dart' hide Split;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_error.dart';
import '../money.dart';
import '../theme.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Splits'),
        actions: [
          if (selection.isNotEmpty)
            TextButton(
              key: const Key('archive-selected'),
              onPressed: () => ref.read(splitsControllerProvider.notifier).archive(selection),
              child: Text('Archive (${selection.length})'),
            ),
          IconButton(
            key: const Key('new-split'),
            icon: const Icon(Icons.add),
            onPressed: () => openSplitForm(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(splitsProvider),
        child: switch (splits) {
          AsyncData(value: final splits) when splits.isEmpty => const _Message('No splits yet.'),
          AsyncData(value: final splits) => ListView.separated(
            itemCount: splits.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, index) =>
                _Row(split: splits[index], selected: selection.contains(splits[index].id)),
          ),
          AsyncError(:final error) => _Message('$error'),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

Future<void> openSplitForm(BuildContext context, {Split? split}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => SplitForm(split: split),
);

class _Row extends ConsumerWidget {
  const _Row({required this.split, required this.selected});

  final Split split;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = split.splitLines.fold(money('0'), (sum, line) => sum + money(line.amount));

    return ListTile(
      key: Key('split-${split.id}'),
      onTap: () => openSplitForm(context, split: split),
      leading: Checkbox(
        key: Key('select-split-${split.id}'),
        value: selected,
        onChanged: (_) => ref.read(splitSelectionProvider.notifier).toggle(split.id),
      ),
      title: Text(split.name),
      subtitle: Text(
        '${split.splitLines.length} ${split.splitLines.length == 1 ? 'line' : 'lines'}',
        style: const TextStyle(color: SpendableColors.muted, fontSize: 12),
      ),
      trailing: Text(formatCurrency(total), style: const TextStyle(fontWeight: FontWeight.w600)),
    );
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
