import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendable/api/api_client.dart';
import 'package:spendable/auth/auth_controller.dart';
import 'package:spendable/auth/identity_tokens.dart';
import 'package:spendable/auth/sign_in_screen.dart';
import 'package:spendable/auth/token_storage.dart';

import '../support/fakes.dart';

Future<void> _pump(
  WidgetTester tester, {
  required FakeIdentityTokens identities,
  required FakeApi api,
  FakeTokenStorage? storage,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(storage ?? FakeTokenStorage()),
        identityTokensProvider.overrideWithValue(identities),
        deviceNameProvider.overrideWith((ref) async => 'iPhone'),
        apiProvider.overrideWithValue(api.build()),
      ],
      child: const MaterialApp(home: SignInScreen()),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('offers both ways in', (tester) async {
    await _pump(tester, identities: FakeIdentityTokens(), api: FakeApi({}));

    expect(find.byKey(const Key('sign-in-apple')), findsOneWidget);
    expect(find.byKey(const Key('sign-in-google')), findsOneWidget);
  });

  testWidgets('tapping a provider signs in with it', (tester) async {
    final identities = FakeIdentityTokens(token: 'id-token');
    final storage = FakeTokenStorage();

    await _pump(
      tester,
      identities: identities,
      storage: storage,
      api: FakeApi({
        'POST /api/session': (
          status: 201,
          body: {'token': 'apt_fresh', 'expires_at': '2026-11-13T00:00:00Z'},
        ),
      }),
    );

    await tester.tap(find.byKey(const Key('sign-in-apple')));
    await tester.pumpAndSettle();

    expect(identities.requested, [AuthProvider.apple]);
    expect(storage.token, 'apt_fresh');
  });

  testWidgets('shows what the server said when sign-in is refused', (tester) async {
    await _pump(
      tester,
      identities: FakeIdentityTokens(token: 'forged'),
      api: FakeApi({
        'POST /api/session': (
          status: 401,
          body: {
            'errors': [
              {'code': 'invalid_id_token', 'detail': 'could not be verified'},
            ],
          },
        ),
      }),
    );

    await tester.tap(find.byKey(const Key('sign-in-google')));
    await tester.pumpAndSettle();

    expect(find.text('could not be verified'), findsOneWidget);
  });
}
