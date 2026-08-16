// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banks_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Connecting banks and deciding what each account does. Kept alive because a resumed OAuth
/// redirect reaches it before any screen is watching, and an auto-disposed notifier would be
/// collected out from under the write.

@ProviderFor(BanksController)
final banksControllerProvider = BanksControllerProvider._();

/// Connecting banks and deciding what each account does. Kept alive because a resumed OAuth
/// redirect reaches it before any screen is watching, and an auto-disposed notifier would be
/// collected out from under the write.
final class BanksControllerProvider
    extends $NotifierProvider<BanksController, AsyncValue<void>> {
  /// Connecting banks and deciding what each account does. Kept alive because a resumed OAuth
  /// redirect reaches it before any screen is watching, and an auto-disposed notifier would be
  /// collected out from under the write.
  BanksControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'banksControllerProvider',
        isAutoDispose: false,
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
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$banksControllerHash() => r'd41105980e07df6f9e14e0c1bd3e1ca97a18a75e';

/// Connecting banks and deciding what each account does. Kept alive because a resumed OAuth
/// redirect reaches it before any screen is watching, and an auto-disposed notifier would be
/// collected out from under the write.

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
