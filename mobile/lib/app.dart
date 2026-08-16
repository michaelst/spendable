import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/auth_controller.dart';
import 'auth/sign_in_screen.dart';
import 'banks/plaid_oauth_links.dart';
import 'push/push_controller.dart';
import 'shell.dart';
import 'theme.dart';

class SpendableApp extends ConsumerWidget {
  const SpendableApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    // Nothing renders these; they just have to be alive to catch a bank's OAuth redirect on
    // launch, and to answer what APNs sends.
    ref.watch(plaidOAuthResumeProvider);
    ref.watch(pushControllerProvider);

    return MaterialApp(
      title: 'Spendable',
      theme: spendableTheme(),
      debugShowCheckedModeBanner: false,
      // Null only while the first Keychain read is in flight. Signing in and out never puts this
      // back into loading, so the screen cannot fall back to the splash mid-flow.
      home: switch (auth.value) {
        true => const Shell(),
        false => const SignInScreen(),
        null => const _Splash(),
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
