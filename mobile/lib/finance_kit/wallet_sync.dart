import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';
import 'wallet.g.dart';
import 'wallet_mapper.dart';

part 'wallet_sync.g.dart';

/// What the app needs from the device, named by the app so a test can stand in for it. The
/// generated `WalletApi` carries pigeon's own plumbing, which nothing here wants to know about.
abstract interface class Wallet {
  Future<bool> isAvailable();

  Future<WalletAuthorization> authorizationStatus();

  Future<WalletAuthorization> requestAuthorization();

  Future<WalletChanges> read(String? historyToken);
}

class PigeonWallet implements Wallet {
  PigeonWallet([WalletApi? api]) : _api = api ?? WalletApi();

  final WalletApi _api;

  @override
  Future<bool> isAvailable() => _api.isAvailable();

  @override
  Future<WalletAuthorization> authorizationStatus() => _api.authorizationStatus();

  @override
  Future<WalletAuthorization> requestAuthorization() => _api.requestAuthorization();

  @override
  Future<WalletChanges> read(String? historyToken) => _api.read(historyToken);
}

@Riverpod(keepAlive: true)
Wallet wallet(Ref ref) => PigeonWallet();

@Riverpod(keepAlive: true)
WalletSync walletSync(Ref ref) => WalletSync(ref.read(apiProvider).getBanksApi(), ref.read(walletProvider));

/// False below iOS 17.4 and outside the US, where offering to connect Wallet would be a dead end.
@Riverpod(keepAlive: true)
Future<bool> walletAvailable(Ref ref) => ref.read(walletSyncProvider).isAvailable;

/// Wallet is read on launch and again whenever the app comes back, because a purchase made while
/// it was away is exactly what the user opens it to see.
@Riverpod(keepAlive: true)
AppLifecycleListener walletAutoSync(Ref ref) {
  final sync = ref.read(walletSyncProvider);

  unawaited(sync.syncIfAuthorized());

  final listener = AppLifecycleListener(onResume: () => unawaited(sync.syncIfAuthorized()));

  ref.onDispose(listener.dispose);

  return listener;
}

/// Reads Wallet on the device and sends what it finds to the server.
class WalletSync {
  WalletSync(this._api, this._wallet);

  final BanksApi _api;
  final Wallet _wallet;

  Future<bool> get isAvailable => _wallet.isAvailable();

  /// Asks for authorization if it has not been asked for yet, then does a first read. Returns
  /// false when the user says no, which is not an error worth showing them.
  Future<bool> connect() async {
    if (!await _wallet.isAvailable()) return false;

    final status = await _wallet.authorizationStatus();

    final authorized = status == WalletAuthorization.authorized
        ? status
        : await _wallet.requestAuthorization();

    if (authorized != WalletAuthorization.authorized) return false;

    await sync();

    return true;
  }

  /// One read, sent as one batch. The server refuses a batch that does not start where it thinks
  /// the device is, and the answer to that is to read again from where the server actually is -
  /// which is what the connection endpoint hands back.
  Future<void> sync() async {
    final connection = await _api.connectFinanceKit().orApiError();
    final member = connection.data!;

    final changes = await _wallet.read(member.historyToken);

    await _api
        .applyFinanceKitChanges(
          id: member.id,
          financeKitChanges: buildChanges(changes, historyTokenBefore: member.historyToken),
        )
        .orApiError();
  }

  /// Sync if Wallet is already authorized, and say nothing when it is not. Called on launch and
  /// on resume, where a prompt would come out of nowhere and a failure is not worth a snackbar.
  Future<void> syncIfAuthorized() async {
    try {
      if (!await _wallet.isAvailable()) return;
      if (await _wallet.authorizationStatus() != WalletAuthorization.authorized) return;

      await sync();
    } on ApiError {
      return;
    } on DioException {
      return;
    } on PlatformException {
      return;
    }
  }
}
