import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendable/api/api_client.dart';
import 'package:spendable/api/api_error.dart';
import 'package:spendable/auth/auth_controller.dart';
import 'package:spendable/auth/identity_tokens.dart';
import 'package:spendable/auth/token_storage.dart';

import '../support/fakes.dart';

const _session = {'token': 'apt_fresh', 'device_name': 'iPhone', 'expires_at': '2026-11-13T00:00:00Z'};

ProviderContainer _container({
  required FakeTokenStorage storage,
  required FakeIdentityTokens identities,
  required FakeApi api,
}) {
  final container = ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(storage),
      identityTokensProvider.overrideWithValue(identities),
      deviceNameProvider.overrideWith((ref) async => 'iPhone'),
      apiProvider.overrideWithValue(api.build()),
    ],
  );

  addTearDown(container.dispose);

  return container;
}

void main() {
  test('signing in stores the token and flips the session on', () async {
    final storage = FakeTokenStorage();
    final api = FakeApi({'POST /api/session': (status: 201, body: _session)});

    final container = _container(
      storage: storage,
      identities: FakeIdentityTokens(token: 'id-token'),
      api: api,
    );

    await container.read(authControllerProvider.notifier).signIn(AuthProvider.google);

    expect(storage.token, 'apt_fresh');
    expect(await container.read(authStateProvider.future), isTrue);
    expect(api.requests.single.data, containsPair('provider', 'google'));
    expect(api.requests.single.data, containsPair('device_name', 'iPhone'));
  });

  test('backing out of the native sheet changes nothing', () async {
    final storage = FakeTokenStorage();
    final api = FakeApi({});

    final container = _container(storage: storage, identities: FakeIdentityTokens(), api: api);

    await container.read(authControllerProvider.notifier).signIn(AuthProvider.apple);

    expect(storage.token, isNull);
    expect(container.read(authControllerProvider).hasError, isFalse);
    expect(api.requests, isEmpty);
  });

  test('an ID token the provider did not sign surfaces the server code', () async {
    final container = _container(
      storage: FakeTokenStorage(),
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

    await container.read(authControllerProvider.notifier).signIn(AuthProvider.apple);

    final error = container.read(authControllerProvider).error;

    expect(error, isA<ApiError>().having((e) => e.code, 'code', 'invalid_id_token'));
    expect(await container.read(authStateProvider.future), isFalse);
  });

  test('signing out revokes the token and clears it', () async {
    final storage = FakeTokenStorage('apt_old');
    final api = FakeApi({'DELETE /api/session': (status: 204, body: null)});

    final container = _container(storage: storage, identities: FakeIdentityTokens(), api: api);

    await container.read(authControllerProvider.notifier).signOut();

    expect(storage.token, isNull);
    expect(container.read(authStateProvider).value, isFalse);
    expect(api.requests.single.method, 'DELETE');
  });

  // The row may already be gone server-side, and the app cannot stay signed in either way.
  test('signing out clears the token even when the server refuses', () async {
    final storage = FakeTokenStorage('apt_old');

    final container = _container(
      storage: storage,
      identities: FakeIdentityTokens(),
      api: FakeApi({'DELETE /api/session': (status: 401, body: null)}),
    );

    await container.read(authControllerProvider.notifier).signOut();

    expect(storage.token, isNull);
    expect(container.read(authStateProvider).value, isFalse);
  });

  test('a rejected token ends the session', () async {
    final storage = FakeTokenStorage('apt_revoked');

    final container = _container(storage: storage, identities: FakeIdentityTokens(), api: FakeApi({}));

    await container.read(authStateProvider.future);
    await container.read(authStateProvider.notifier).sessionExpired();

    expect(storage.token, isNull);
    expect(container.read(authStateProvider).value, isFalse);
  });
}
