// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splits_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Writing splits. Archiving several is N requests rather than a bulk endpoint, because a user
/// has a handful of splits, not a page of them.

@ProviderFor(SplitsController)
final splitsControllerProvider = SplitsControllerProvider._();

/// Writing splits. Archiving several is N requests rather than a bulk endpoint, because a user
/// has a handful of splits, not a page of them.
final class SplitsControllerProvider
    extends $NotifierProvider<SplitsController, AsyncValue<void>> {
  /// Writing splits. Archiving several is N requests rather than a bulk endpoint, because a user
  /// has a handful of splits, not a page of them.
  SplitsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splitsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splitsControllerHash();

  @$internal
  @override
  SplitsController create() => SplitsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$splitsControllerHash() => r'cb30708c5def3eb20ed95e7a732db39a3da10c76';

/// Writing splits. Archiving several is N requests rather than a bulk endpoint, because a user
/// has a handful of splits, not a page of them.

abstract class _$SplitsController extends $Notifier<AsyncValue<void>> {
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
