import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendable/api/api_client.dart';

import '../support/fakes.dart';

/// Drives the interceptors the way the app installs them, through a real dio call.
Future<RequestOptions> _get(FakeApi api, List<Interceptor> interceptors) async {
  final client = api.build(interceptors: interceptors);

  try {
    await client.getSessionApi().getCurrentUser();
  } on DioException {
    // Every case here answers 401; what is under test is what the interceptors did with it.
  }

  return api.requests.single;
}

void main() {
  group('BearerTokenInterceptor', () {
    test('attaches the stored token', () async {
      final api = FakeApi({'GET /api/me': (status: 401, body: null)});

      final request = await _get(api, [BearerTokenInterceptor(FakeTokenStorage('apt_secret'))]);

      expect(request.headers['authorization'], 'Bearer apt_secret');
    });

    test('sends nothing when there is no token', () async {
      final api = FakeApi({'GET /api/me': (status: 401, body: null)});

      final request = await _get(api, [BearerTokenInterceptor(FakeTokenStorage())]);

      expect(request.headers.containsKey('authorization'), isFalse);
    });
  });

  group('UnauthorizedInterceptor', () {
    test('ends the session when a request that carried a token is refused', () async {
      var expired = false;
      final api = FakeApi({'GET /api/me': (status: 401, body: null)});

      await _get(api, [
        BearerTokenInterceptor(FakeTokenStorage('apt_revoked')),
        UnauthorizedInterceptor(() async => expired = true),
      ]);

      expect(expired, isTrue);
    });

    // Sign-in answers 401 for an ID token the provider did not sign, and there is no session
    // to end yet.
    test('leaves an unauthenticated request alone', () async {
      var expired = false;
      final api = FakeApi({'GET /api/me': (status: 401, body: null)});

      await _get(api, [
        BearerTokenInterceptor(FakeTokenStorage()),
        UnauthorizedInterceptor(() async => expired = true),
      ]);

      expect(expired, isFalse);
    });
  });
}
