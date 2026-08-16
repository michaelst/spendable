import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spendable_api/spendable_api.dart';

import '../auth/auth_controller.dart';
import '../auth/token_storage.dart';

part 'api_client.g.dart';

/// Point a device at a dev server with
/// `flutter run --dart-define=SPENDABLE_API_URL=http://192.168.1.10:4000`.
const _baseUrl = String.fromEnvironment('SPENDABLE_API_URL', defaultValue: 'https://spendable.money');

@Riverpod(keepAlive: true)
SpendableApi api(Ref ref) {
  final storage = ref.watch(tokenStorageProvider);

  return SpendableApi(
    basePathOverride: _baseUrl,
    interceptors: [
      BearerTokenInterceptor(storage),
      UnauthorizedInterceptor(() => ref.read(authStateProvider.notifier).sessionExpired()),
    ],
  );
}

class BearerTokenInterceptor extends Interceptor {
  BearerTokenInterceptor(this._storage);

  final TokenStorage _storage;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read();

    if (token != null) options.headers['authorization'] = 'Bearer $token';

    handler.next(options);
  }
}

/// A 401 on a request that carried a token means the server revoked or expired it, so nothing
/// the app holds is usable any more. Sign-in itself answers 401 for a bad ID token and carries
/// no header, which is why the check is on the header rather than the status alone.
class UnauthorizedInterceptor extends Interceptor {
  UnauthorizedInterceptor(this._onExpired);

  final Future<void> Function() _onExpired;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final authenticated = err.requestOptions.headers.containsKey('authorization');

    if (err.response?.statusCode == 401 && authenticated) unawaited(_onExpired());

    handler.next(err);
  }
}
