import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_storage.g.dart';

/// Where the API token lives. An interface so tests do not need a Keychain.
abstract interface class TokenStorage {
  Future<String?> read();

  Future<void> write(String token);

  Future<void> clear();
}

/// `first_unlock` rather than the default, so a background refresh after a reboot can still
/// read the token.
class KeychainTokenStorage implements TokenStorage {
  KeychainTokenStorage([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock));

  static const _key = 'api_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

@Riverpod(keepAlive: true)
TokenStorage tokenStorage(Ref ref) => KeychainTokenStorage();
