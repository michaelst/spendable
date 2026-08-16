import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:spendable/auth/identity_tokens.dart';
import 'package:spendable/auth/token_storage.dart';
import 'package:spendable/push/push_channel.dart';
import 'package:spendable_api/spendable_api.dart';

class FakeTokenStorage implements TokenStorage {
  FakeTokenStorage([this.token]);

  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String value) async => token = value;

  @override
  Future<void> clear() async => token = null;
}

class FakeIdentityTokens implements IdentityTokens {
  FakeIdentityTokens({this.token, this.throws});

  /// Null stands for the user backing out of the native sheet.
  final String? token;
  final Object? throws;

  final requested = <AuthProvider>[];

  @override
  Future<String?> fetch(AuthProvider provider) async {
    requested.add(provider);

    if (throws case final error?) throw error;

    return token;
  }
}

class FakePushChannel implements PushChannel {
  FakePushChannel({this.granted = true});

  final bool granted;
  final _events = StreamController<PushEvent>.broadcast();

  var registered = 0;

  @override
  Stream<PushEvent> get events => _events.stream;

  @override
  Future<bool> register() async {
    registered += 1;

    return granted;
  }

  /// Stands in for the device: what iOS would have sent up the channel.
  void send(PushEvent event) => _events.add(event);
}

/// One canned reply per `METHOD /path`, so a test states only the calls it cares about.
class FakeApi {
  FakeApi(this.replies);

  final Map<String, ({int status, Object? body})> replies;

  final requests = <RequestOptions>[];

  SpendableApi build({List<Interceptor> interceptors = const []}) {
    final dio = Dio(BaseOptions(baseUrl: 'https://spendable.test'))..httpClientAdapter = _Adapter(this);

    return SpendableApi(dio: dio, interceptors: interceptors);
  }
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this._api);

  final FakeApi _api;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream, Future<void>? cancel) async {
    _api.requests.add(options);

    final reply = _api.replies['${options.method} ${options.path}'];

    if (reply == null) throw StateError('no reply for ${options.method} ${options.path}');

    return ResponseBody.fromString(
      reply.body == null ? '' : jsonEncode(reply.body),
      reply.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
