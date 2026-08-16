// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Attaching and removing ways of signing in. Linking is an authenticated action rather than
/// something inferred from a shared email, because Spendable stores no email to match on.

@ProviderFor(IdentityController)
final identityControllerProvider = IdentityControllerProvider._();

/// Attaching and removing ways of signing in. Linking is an authenticated action rather than
/// something inferred from a shared email, because Spendable stores no email to match on.
final class IdentityControllerProvider extends $NotifierProvider<IdentityController, AsyncValue<void>> {
  /// Attaching and removing ways of signing in. Linking is an authenticated action rather than
  /// something inferred from a shared email, because Spendable stores no email to match on.
  IdentityControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'identityControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$identityControllerHash();

  @$internal
  @override
  IdentityController create() => IdentityController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<AsyncValue<void>>(value));
  }
}

String _$identityControllerHash() => r'8d5b40c89972809f4bb7778c039b065531b3fe3e';

/// Attaching and removing ways of signing in. Linking is an authenticated action rather than
/// something inferred from a shared email, because Spendable stores no email to match on.

abstract class _$IdentityController extends $Notifier<AsyncValue<void>> {
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
