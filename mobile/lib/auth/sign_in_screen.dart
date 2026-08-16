import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme.dart';
import 'auth_controller.dart';
import 'identity_tokens.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Spendable', style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 8),
                  const Text('Know what is left to spend.', style: TextStyle(color: SpendableColors.muted)),
                  const SizedBox(height: 48),
                  for (final provider in AuthProvider.values) ...[
                    _ProviderButton(
                      provider: provider,
                      enabled: !auth.isLoading,
                      onPressed: () => ref.read(authControllerProvider.notifier).signIn(provider),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (auth.hasError) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${auth.error}',
                      key: const Key('sign-in-error'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: SpendableColors.negative),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({required this.provider, required this.enabled, required this.onPressed});

  final AuthProvider provider;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: Key('sign-in-${provider.name}'),
      onPressed: enabled ? onPressed : null,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: SpendableColors.surface,
        foregroundColor: Colors.white,
      ),
      child: Text(provider.label),
    );
  }
}
