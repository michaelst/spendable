// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(wallet)
final walletProvider = WalletProvider._();

final class WalletProvider extends $FunctionalProvider<Wallet, Wallet, Wallet>
    with $Provider<Wallet> {
  WalletProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletHash();

  @$internal
  @override
  $ProviderElement<Wallet> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Wallet create(Ref ref) {
    return wallet(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Wallet value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Wallet>(value),
    );
  }
}

String _$walletHash() => r'1e2b2fc56a3eeac65c76f6ec30096a5aa0193763';

@ProviderFor(walletSync)
final walletSyncProvider = WalletSyncProvider._();

final class WalletSyncProvider
    extends $FunctionalProvider<WalletSync, WalletSync, WalletSync>
    with $Provider<WalletSync> {
  WalletSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletSyncHash();

  @$internal
  @override
  $ProviderElement<WalletSync> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WalletSync create(Ref ref) {
    return walletSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WalletSync value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WalletSync>(value),
    );
  }
}

String _$walletSyncHash() => r'f45b4da85771fcbeedb91759419cd7e2ab251767';

/// False below iOS 17.4 and outside the US, where offering to connect Wallet would be a dead end.

@ProviderFor(walletAvailable)
final walletAvailableProvider = WalletAvailableProvider._();

/// False below iOS 17.4 and outside the US, where offering to connect Wallet would be a dead end.

final class WalletAvailableProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// False below iOS 17.4 and outside the US, where offering to connect Wallet would be a dead end.
  WalletAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletAvailableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletAvailableHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return walletAvailable(ref);
  }
}

String _$walletAvailableHash() => r'8bd044384a2fb951b307f507c540f61a9bae1a95';

/// Wallet is read on launch and again whenever the app comes back, because a purchase made while
/// it was away is exactly what the user opens it to see.

@ProviderFor(walletAutoSync)
final walletAutoSyncProvider = WalletAutoSyncProvider._();

/// Wallet is read on launch and again whenever the app comes back, because a purchase made while
/// it was away is exactly what the user opens it to see.

final class WalletAutoSyncProvider
    extends
        $FunctionalProvider<
          AppLifecycleListener,
          AppLifecycleListener,
          AppLifecycleListener
        >
    with $Provider<AppLifecycleListener> {
  /// Wallet is read on launch and again whenever the app comes back, because a purchase made while
  /// it was away is exactly what the user opens it to see.
  WalletAutoSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletAutoSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletAutoSyncHash();

  @$internal
  @override
  $ProviderElement<AppLifecycleListener> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppLifecycleListener create(Ref ref) {
    return walletAutoSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLifecycleListener value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLifecycleListener>(value),
    );
  }
}

String _$walletAutoSyncHash() => r'2b35fa8bcceb5edddfc7f2bb4159b33f5c61a7d9';
