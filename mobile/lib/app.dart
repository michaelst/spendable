import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/account_screen.dart';
import 'auth/auth_controller.dart';
import 'auth/sign_in_screen.dart';
import 'theme.dart';

class SpendableApp extends ConsumerWidget {
  const SpendableApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Spendable',
      theme: spendableTheme(),
      debugShowCheckedModeBanner: false,
      // Null only while the first Keychain read is in flight. Signing in and out never puts this
      // back into loading, so the screen cannot fall back to the splash mid-flow.
      home: switch (auth.value) {
        true => const AccountScreen(),
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
