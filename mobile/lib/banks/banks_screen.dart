import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendable_api/spendable_api.dart';

import '../money.dart';
import '../theme.dart';
import '../budgets/budgets_providers.dart';
import 'banks_controller.dart';
import 'banks_providers.dart';

class BanksScreen extends ConsumerWidget {
  const BanksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(bankMembersProvider);
    final busy = ref.watch(banksControllerProvider).isLoading;

    ref.listen(banksControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text('$error')));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Banks'),
        actions: [
          IconButton(
            key: const Key('connect-bank'),
            icon: const Icon(Icons.add),
            onPressed: busy ? null : ref.read(banksControllerProvider.notifier).connect,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(bankMembersProvider),
        child: switch (members) {
          AsyncData(value: final members) when members.isEmpty => const _Message('No banks connected.'),
          AsyncData(value: final members) => ListView(
            children: [for (final member in members) _Member(member: member)],
          ),
          AsyncError(:final error) => _Message('$error'),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _Member extends ConsumerWidget {
  const _Member({required this.member});

  final BankMember member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(banksControllerProvider.notifier);

    // Anything other than CONNECTED means Plaid needs the user to go back through Link.
    final connected = member.status == 'CONNECTED';

    return ExpansionTile(
      key: Key('member-${member.id}'),
      leading: member.hasLogo ? _Logo(memberId: member.id) : const Icon(Icons.account_balance),
      title: Text(member.name),
      subtitle: connected ? null : const Text('Reconnect', style: TextStyle(color: SpendableColors.negative)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!connected)
            TextButton(
              key: Key('reconnect-${member.id}'),
              onPressed: () => controller.reconnect(member.id),
              child: const Text('Reconnect'),
            ),
          IconButton(
            key: Key('sync-${member.id}'),
            tooltip: 'Sync history',
            icon: const Icon(Icons.history),
            onPressed: () => _syncHistory(context, ref, member.id),
          ),
        ],
      ),
      children: [for (final account in member.bankAccounts) _Account(account: account)],
    );
  }

  Future<void> _syncHistory(BuildContext context, WidgetRef ref, String memberId) async {
    final queued = await ref.read(banksControllerProvider.notifier).syncHistory(memberId);

    if (!queued || !context.mounted) return;

    // The job answers nothing when it finishes, so say so rather than implying a wait.
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(content: Text('Syncing history. Pull to refresh to see what has landed.')),
      );
  }
}

class _Logo extends ConsumerWidget {
  const _Logo({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 32,
      height: 32,
      child: switch (ref.watch(bankLogoProvider(memberId))) {
        AsyncData(value: final bytes) => Image.memory(bytes, fit: BoxFit.contain),
        _ => const Icon(Icons.account_balance),
      },
    );
  }
}

class _Account extends ConsumerWidget {
  const _Account({required this.account});

  final BankAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(banksControllerProvider.notifier);
    final budgets = ref.watch(budgetOptionsProvider).value ?? const <Budget>[];

    // An account that is not synced counts toward nothing, and reads that way.
    final color = account.sync_ ? Colors.white : SpendableColors.muted;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${account.name} ••••${account.number ?? ''}',
                      style: TextStyle(color: color, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      account.subType.toUpperCase(),
                      style: const TextStyle(color: SpendableColors.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(formatCurrency(money(account.balance)), style: TextStyle(color: color)),
              Switch(
                key: Key('sync-account-${account.id}'),
                value: account.sync_,
                onChanged: (value) => controller.setSync(account, sync: value),
              ),
            ],
          ),
          DropdownButtonFormField<String?>(
            key: Key('budget-for-${account.id}'),
            initialValue: account.budgetId,
            isExpanded: true,
            decoration: const InputDecoration(isDense: true),
            items: [
              const DropdownMenuItem(child: Text('Assign to budget')),
              for (final budget in budgets)
                DropdownMenuItem(
                  value: budget.id,
                  child: Text(budget.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (value) => controller.assignBudget(account, value),
          ),
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
