// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Labels the token row so the account screen can tell one device from another.

@ProviderFor(deviceName)
final deviceNameProvider = DeviceNameProvider._();

/// Labels the token row so the account screen can tell one device from another.

final class DeviceNameProvider extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Labels the token row so the account screen can tell one device from another.
  DeviceNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceNameProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceNameHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return deviceName(ref);
  }
}

String _$deviceNameHash() => r'1fcec42bdebc23d22d480de68942d6249b279656';

/// Whether a token is held, and nothing else - everything about the account itself comes from
/// `GET /api/me`. Kept apart from [AuthController] so a sign-in attempt in flight never leaves
/// the app unsure which screen it is on.

@ProviderFor(AuthState)
final authStateProvider = AuthStateProvider._();

/// Whether a token is held, and nothing else - everything about the account itself comes from
/// `GET /api/me`. Kept apart from [AuthController] so a sign-in attempt in flight never leaves
/// the app unsure which screen it is on.
final class AuthStateProvider extends $AsyncNotifierProvider<AuthState, bool> {
  /// Whether a token is held, and nothing else - everything about the account itself comes from
  /// `GET /api/me`. Kept apart from [AuthController] so a sign-in attempt in flight never leaves
  /// the app unsure which screen it is on.
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  AuthState create() => AuthState();
}

String _$authStateHash() => r'835d9d12040e825f553f7ad393717d81d5f2b36a';

/// Whether a token is held, and nothing else - everything about the account itself comes from
/// `GET /api/me`. Kept apart from [AuthController] so a sign-in attempt in flight never leaves
/// the app unsure which screen it is on.

abstract class _$AuthState extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<AsyncValue<bool>, bool>, AsyncValue<bool>, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Signing in and out. Its own state is the progress and failure of the attempt.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Signing in and out. Its own state is the progress and failure of the attempt.
final class AuthControllerProvider extends $NotifierProvider<AuthController, AsyncValue<void>> {
  /// Signing in and out. Its own state is the progress and failure of the attempt.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<AsyncValue<void>>(value));
  }
}

String _$authControllerHash() => r'e1e1d2273f02015ea367b1dbe572ae3ae1e4ded3';

/// Signing in and out. Its own state is the progress and failure of the attempt.

abstract class _$AuthController extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
