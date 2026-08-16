import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design/primary_button.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import 'auth_controller.dart';
import 'identity_tokens.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SpendableColors.of(context);
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpendableSpace.block),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Spendable', style: SpendableType.moneyHero.copyWith(color: colors.primary)),
                  const SizedBox(height: SpendableSpace.hair),
                  Text(
                    'Know what is left to spend.',
                    style: SpendableType.body.copyWith(color: colors.secondary),
                  ),
                  const SizedBox(height: 48),
                  for (final provider in AuthProvider.values) ...[
                    PrimaryButton(
                      key: Key('sign-in-${provider.name}'),
                      label: provider.label,
                      // The second way in is offered, not urged, so only the first is filled.
                      variant: provider == AuthProvider.values.first
                          ? ButtonVariant.filled
                          : ButtonVariant.plain,
                      onPressed: auth.isLoading
                          ? null
                          : () => ref.read(authControllerProvider.notifier).signIn(provider),
                    ),
                    const SizedBox(height: SpendableSpace.step),
                  ],
                  if (auth.hasError)
                    Text(
                      '${auth.error}',
                      key: const Key('sign-in-error'),
                      textAlign: TextAlign.center,
                      style: SpendableType.subhead.copyWith(color: colors.negative),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
