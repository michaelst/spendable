import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendable_api/spendable_api.dart';

import '../theme.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          TextButton(
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(currentUserProvider),
        child: switch (user) {
          AsyncData(value: final user) => _Identities(user: user),
          AsyncError(:final error) => _Message('$error'),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
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
    final linked = {for (final identity in user.identities) identity.provider.name: identity};
    final busy = ref.watch(identityControllerProvider).isLoading;

    return ListView(
      children: [
        const _SectionHeader('Ways to sign in'),
        for (final provider in AuthProvider.values)
          switch (linked[provider.name]) {
            final Identity identity => ListTile(
              title: Text(provider.name),
              subtitle: const Text('Linked', style: TextStyle(color: SpendableColors.positive)),
              trailing: TextButton(
                // Removing the last one is refused by the server, which answers 409.
                key: Key('unlink-${provider.name}'),
                onPressed: busy
                    ? null
                    : () => ref.read(identityControllerProvider.notifier).unlink(identity.id),
                child: const Text('Remove'),
              ),
            ),
            null => ListTile(
              title: Text(provider.name),
              subtitle: const Text('Not linked', style: TextStyle(color: SpendableColors.muted)),
              trailing: TextButton(
                key: Key('link-${provider.name}'),
                onPressed: busy ? null : () => ref.read(identityControllerProvider.notifier).link(provider),
                child: const Text('Add'),
              ),
            ),
          },
        const _SectionHeader('Banks'),
        ListTile(
          title: const Text('Connections allowed'),
          trailing: Text('${user.bankLimit}', style: const TextStyle(color: SpendableColors.muted)),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: SpendableColors.muted, fontSize: 12, letterSpacing: 0.8),
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
