import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../design/primary_button.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import 'auth_controller.dart';
import 'identity_tokens.dart';

final _privacyPolicy = Uri.parse('https://spendable.money/privacy-policy');

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SpendableColors.of(context);
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpendableSpace.block),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(child: _LogoTile()),
                        const SizedBox(height: SpendableSpace.block),
                        Center(
                          child: SvgPicture.asset(
                            'assets/brand/wordmark.svg',
                            height: 26,
                            colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
                          ),
                        ),
                        const SizedBox(height: SpendableSpace.step),
                        Text(
                          'Open source. No ads. Your financial data is never sold.',
                          textAlign: TextAlign.center,
                          style: SpendableType.body.copyWith(color: colors.secondary),
                        ),
                        const SizedBox(height: 40),
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
              const _PrivacyNote(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The app icon itself, so the screen opens on the thing that was tapped to reach it. Its ground is
/// the mark's own black in either theme, the way an icon does not restyle for dark mode.
class _LogoTile extends StatelessWidget {
  const _LogoTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: const Color(0xFF121110), borderRadius: BorderRadius.circular(20)),
      child: SvgPicture.asset(
        'assets/brand/mark.svg',
        width: 42,
        height: 42,
        colorFilter: const ColorFilter.mode(Color(0xFFFFFEFD), BlendMode.srcIn),
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);

    return Column(
      children: [
        Container(height: 1, color: colors.separator),
        GestureDetector(
          key: const Key('privacy-policy'),
          behavior: HitTestBehavior.opaque,
          onTap: () => launchUrl(_privacyPolicy, mode: LaunchMode.externalApplication),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: SpendableSpace.gutter),
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Read the '),
                  TextSpan(
                    text: 'privacy policy',
                    style: TextStyle(color: colors.accent, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              style: SpendableType.subhead.copyWith(color: colors.tertiary),
            ),
          ),
        ),
      ],
    );
  }
}
