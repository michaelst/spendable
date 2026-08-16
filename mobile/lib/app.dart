import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/auth_controller.dart';
import 'auth/sign_in_screen.dart';
import 'banks/plaid_oauth_links.dart';
import 'design/theme.dart';
import 'shell.dart';

class SpendableApp extends ConsumerStatefulWidget {
  const SpendableApp({super.key});

  @override
  ConsumerState<SpendableApp> createState() => _SpendableAppState();
}

class _SpendableAppState extends ConsumerState<SpendableApp> {
  final _navigator = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);

    // Nothing renders it; it just has to be alive to catch a bank's OAuth redirect on launch.
    ref.watch(plaidOAuthResumeProvider);

    // Signing out swaps the home screen underneath whatever was pushed on top of it, so the
    // account screen would otherwise stay up over the sign-in screen.
    ref.listen(authStateProvider, (_, next) {
      if (next.value == false) _navigator.currentState?.popUntil((route) => route.isFirst);
    });

    return MaterialApp(
      navigatorKey: _navigator,
      title: 'Spendable',
      theme: spendableTheme(Brightness.light),
      darkTheme: spendableTheme(Brightness.dark),
      themeMode: ThemeMode.system,
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
