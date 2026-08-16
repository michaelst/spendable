import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendable/api/api_client.dart';
import 'package:spendable/auth/account_screen.dart';
import 'package:spendable/auth/auth_controller.dart';
import 'package:spendable/auth/identity_tokens.dart';
import 'package:spendable/auth/token_storage.dart';

import '../support/fakes.dart';

Map<String, Object?> _user(List<Map<String, String>> identities) => {
  'id': 'usr_01',
  'bank_limit': 2,
  'image': null,
  'identities': identities,
};

Future<void> _pump(
  WidgetTester tester, {
  required FakeApi api,
  FakeIdentityTokens? identities,
  FakeTokenStorage? storage,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(storage ?? FakeTokenStorage('apt_live')),
        identityTokensProvider.overrideWithValue(identities ?? FakeIdentityTokens()),
        deviceNameProvider.overrideWith((ref) async => 'iPhone'),
        apiProvider.overrideWithValue(api.build()),
      ],
      child: const MaterialApp(home: AccountScreen()),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('separates the linked providers from the ones still available', (tester) async {
    await _pump(
      tester,
      api: FakeApi({
        'GET /api/me': (
          status: 200,
          body: _user([
            {'id': 'usi_01', 'provider': 'google'},
          ]),
        ),
      }),
    );

    expect(find.byKey(const Key('unlink-google')), findsOneWidget);
    expect(find.byKey(const Key('link-apple')), findsOneWidget);
  });

  testWidgets('adding a provider links it and re-reads the account', (tester) async {
    final identities = FakeIdentityTokens(token: 'id-token');

    final api = FakeApi({
      'GET /api/me': (
        status: 200,
        body: _user([
          {'id': 'usi_01', 'provider': 'google'},
        ]),
      ),
      'POST /api/identities': (status: 201, body: {'id': 'usi_02', 'provider': 'apple'}),
    });

    await _pump(tester, api: api, identities: identities);

    await tester.tap(find.byKey(const Key('link-apple')));
    await tester.pumpAndSettle();

    expect(identities.requested, [AuthProvider.apple]);
    expect(api.requests.map((request) => '${request.method} ${request.path}'), [
      'GET /api/me',
      'POST /api/identities',
      'GET /api/me',
    ]);
  });

  testWidgets('refusing to remove the last way in is reported, not hidden', (tester) async {
    await _pump(
      tester,
      api: FakeApi({
        'GET /api/me': (
          status: 200,
          body: _user([
            {'id': 'usi_01', 'provider': 'google'},
          ]),
        ),
        'DELETE /api/identities/usi_01': (
          status: 409,
          body: {
            'errors': [
              {'code': 'last_identity', 'detail': 'is the only way to sign in'},
            ],
          },
        ),
      }),
    );

    await tester.tap(find.byKey(const Key('unlink-google')));
    await tester.pumpAndSettle();

    expect(find.text('is the only way to sign in'), findsOneWidget);
  });
}
