import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_plaid_session.g.dart';

/// Connecting a new bank ends by exchanging a public token; repairing an existing one ends by
/// doing nothing at all. The redirect that brings the app back says nothing about which, so the
/// answer has to survive iOS terminating the app mid-flow.
enum PlaidSessionKind { connect, reconnect }

abstract interface class PendingPlaidSession {
  Future<PlaidSessionKind?> read();

  Future<void> start(PlaidSessionKind kind);

  Future<void> clear();
}

/// The Keychain rather than shared preferences, only because the app already depends on it -
/// nothing here is sensitive.
class StoredPendingPlaidSession implements PendingPlaidSession {
  StoredPendingPlaidSession([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'pending_plaid_session';

  final FlutterSecureStorage _storage;

  @override
  Future<PlaidSessionKind?> read() async {
    final name = await _storage.read(key: _key);

    return PlaidSessionKind.values.where((kind) => kind.name == name).firstOrNull;
  }

  @override
  Future<void> start(PlaidSessionKind kind) => _storage.write(key: _key, value: kind.name);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

@Riverpod(keepAlive: true)
PendingPlaidSession pendingPlaidSession(Ref ref) => StoredPendingPlaidSession();
