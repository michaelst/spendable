import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendable_api/spendable_api.dart';

import '../budgets/budget_picker.dart';
import '../budgets/budgets_providers.dart';
import '../design/band_button.dart';
import '../design/caption.dart';
import '../design/glyph_icon.dart';
import '../design/ledger_row.dart';
import '../design/ledger_screen.dart';
import '../design/money_text.dart';
import '../design/nav_band.dart';
import '../design/picker_field.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import '../finance_kit/wallet_sync.dart';
import '../money.dart';
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

    return LedgerScreen(
      onRefresh: () async => ref.invalidate(bankMembersProvider),
      band: NavBand(
        title: 'Banks',
        actions: [
          if (ref.watch(walletAvailableProvider).value ?? false)
            BandButton(
              key: const Key('connect-apple'),
              icon: Glyph.wallet,
              onPressed: busy ? null : ref.read(banksControllerProvider.notifier).connectApple,
            ),
          BandButton(
            key: const Key('connect-bank'),
            icon: Glyph.plus,
            onPressed: busy ? null : ref.read(banksControllerProvider.notifier).connect,
          ),
        ],
      ),
      slivers: switch (members) {
        AsyncData(value: final members) when members.isEmpty => const [_Message('No banks connected.')],
        AsyncData(value: final members) => [
          SliverList.builder(
            itemCount: members.length,
            itemBuilder: (_, index) => _Member(member: members[index]),
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

/// A bank and the accounts under it, which stay folded away until the bank is opened.
class _Member extends ConsumerStatefulWidget {
  const _Member({required this.member});

  final BankMember member;

  @override
  ConsumerState<_Member> createState() => _MemberState();
}

class _MemberState extends ConsumerState<_Member> {
  var _open = false;

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);
    final controller = ref.read(banksControllerProvider.notifier);
    final member = widget.member;

    // Anything other than CONNECTED means Plaid needs the user to go back through Link.
    final connected = member.status == 'CONNECTED';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LedgerRow(
          key: Key('member-${member.id}'),
          onTap: () => setState(() => _open = !_open),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: member.hasLogo
                    ? _Logo(memberId: member.id)
                    : GlyphIcon(Glyph.bank, size: 24, color: colors.secondary),
              ),
              const SizedBox(width: SpendableSpace.step),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name, style: SpendableType.title.copyWith(color: colors.primary)),
                    if (!connected) Caption('Reconnect', color: colors.negative),
                  ],
                ),
              ),
              if (!connected)
                BandButton(
                  key: Key('reconnect-${member.id}'),
                  label: 'Reconnect',
                  onPressed: () => controller.reconnect(member.id),
                ),
              RotatedBox(
                quarterTurns: _open ? 1 : 0,
                child: GlyphIcon(Glyph.caretRight, size: 14, color: colors.tertiary),
              ),
            ],
          ),
        ),
        if (_open)
          for (final account in member.bankAccounts) _Account(account: account),
      ],
    );
  }
}

class _Logo extends ConsumerWidget {
  const _Logo({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(bankLogoProvider(memberId))) {
      AsyncData(value: final bytes) => Image.memory(bytes, fit: BoxFit.contain),
      _ => GlyphIcon(Glyph.bank, size: 24, color: SpendableColors.of(context).secondary),
    };
  }
}

class _Account extends ConsumerWidget {
  const _Account({required this.account});

  final BankAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SpendableColors.of(context);
    final controller = ref.read(banksControllerProvider.notifier);
    final budgets = ref.watch(budgetOptionsProvider).value ?? const <Budget>[];

    return LedgerRow(
      // An account that is not synced counts toward nothing, and reads that way.
      dimmed: !account.sync_,
      ruleInset: SpendableSpace.block,
      padding: const EdgeInsets.fromLTRB(
        SpendableSpace.block,
        SpendableSpace.tight,
        SpendableSpace.gutter,
        SpendableSpace.tight,
      ),
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
                      style: SpendableType.body.copyWith(color: colors.primary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Caption(account.subType),
                  ],
                ),
              ),
              MoneyText(money(account.balance), style: SpendableType.moneyInline),
              const SizedBox(width: SpendableSpace.tight),
              Switch.adaptive(
                key: Key('sync-account-${account.id}'),
                value: account.sync_,
                onChanged: (value) => controller.setSync(account, sync: value),
              ),
            ],
          ),
          PickerField(
            key: Key('budget-for-${account.id}'),
            label: 'Assign to budget',
            value: budgets.where((budget) => budget.id == account.budgetId).firstOrNull?.name,
            onTap: () async {
              final chosen = await pickBudget(context, ref);

              if (chosen != null) await controller.assignBudget(account, chosen.id);
            },
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
