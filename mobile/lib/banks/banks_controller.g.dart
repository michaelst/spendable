// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banks_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Connecting banks and deciding what each account does.

@ProviderFor(BanksController)
final banksControllerProvider = BanksControllerProvider._();

/// Connecting banks and deciding what each account does.
final class BanksControllerProvider extends $NotifierProvider<BanksController, AsyncValue<void>> {
  /// Connecting banks and deciding what each account does.
  BanksControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'banksControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$banksControllerHash();

  @$internal
  @override
  BanksController create() => BanksController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<AsyncValue<void>>(value));
  }
}

String _$banksControllerHash() => r'713c7e4a5bf21210234f0c49a844c830c9a6b09f';

/// Connecting banks and deciding what each account does.

abstract class _$BanksController extends $Notifier<AsyncValue<void>> {
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
