import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendable_api/spendable_api.dart';

import '../design/band_button.dart';
import '../design/caption.dart';
import '../design/glyph_icon.dart';
import '../design/ledger_row.dart';
import '../design/ledger_screen.dart';
import '../design/nav_band.dart';
import '../design/section_rule.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import 'auth_controller.dart';
import 'current_user.dart';
import 'identity_controller.dart';
import 'identity_tokens.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    ref.listen(identityControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) _showError(context, error);
    });

    return LedgerScreen(
      onRefresh: () async => ref.invalidate(currentUserProvider),
      band: NavBand(
        title: 'Account',
        leading: BandButton(
          key: const Key('account-back'),
          icon: Glyph.caretLeft,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          BandButton(label: 'Sign out', onPressed: () => ref.read(authControllerProvider.notifier).signOut()),
        ],
      ),
      slivers: switch (user) {
        AsyncData(value: final user) => [SliverToBoxAdapter(child: _Identities(user: user))],
        AsyncError(:final error) => [_Message('$error')],
        _ => const [
          SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator())),
        ],
      },
    );
  }

  void _showError(BuildContext context, Object error) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text('$error')));
  }
}

class _Identities extends ConsumerWidget {
  const _Identities({required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SpendableColors.of(context);
    final linked = {for (final identity in user.identities) identity.provider.name: identity};
    final busy = ref.watch(identityControllerProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionRule('Ways to sign in'),
        for (final provider in AuthProvider.values)
          switch (linked[provider.name]) {
            final Identity identity => _Identity(
              provider: provider,
              status: 'Linked',
              statusColor: colors.positive,
              action: BandButton(
                // Removing the last one is refused by the server, which answers 409.
                key: Key('unlink-${provider.name}'),
                label: 'Remove',
                onPressed: busy
                    ? null
                    : () => ref.read(identityControllerProvider.notifier).unlink(identity.id),
              ),
            ),
            null => _Identity(
              provider: provider,
              status: 'Not linked',
              statusColor: colors.tertiary,
              action: BandButton(
                key: Key('link-${provider.name}'),
                label: 'Add',
                onPressed: busy ? null : () => ref.read(identityControllerProvider.notifier).link(provider),
              ),
            ),
          },
        const SectionRule('Banks'),
        LedgerRow(
          child: Row(
            children: [
              Expanded(
                child: Text('Connections allowed', style: SpendableType.body.copyWith(color: colors.primary)),
              ),
              Text('${user.bankLimit}', style: SpendableType.moneyInline.copyWith(color: colors.secondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({
    required this.provider,
    required this.status,
    required this.statusColor,
    required this.action,
  });

  final AuthProvider provider;
  final String status;
  final Color statusColor;
  final Widget action;

  /// The enum is the wire name; the screen says it the way a person would.
  String _name(AuthProvider provider) => provider.name[0].toUpperCase() + provider.name.substring(1);

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);

    return LedgerRow(
      padding: const EdgeInsets.only(left: SpendableSpace.gutter, right: SpendableSpace.hair),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_name(provider), style: SpendableType.title.copyWith(color: colors.primary)),
                Caption(status, color: statusColor),
              ],
            ),
          ),
          action,
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
