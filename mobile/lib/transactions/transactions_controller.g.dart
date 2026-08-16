// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Writing transactions. Every write renders the transaction that came back rather than what was
/// sent: the server re-runs the allocation split on each save, so the response is the only
/// account of what a transaction now looks like.

@ProviderFor(TransactionsController)
final transactionsControllerProvider = TransactionsControllerProvider._();

/// Writing transactions. Every write renders the transaction that came back rather than what was
/// sent: the server re-runs the allocation split on each save, so the response is the only
/// account of what a transaction now looks like.
final class TransactionsControllerProvider
    extends $NotifierProvider<TransactionsController, AsyncValue<void>> {
  /// Writing transactions. Every write renders the transaction that came back rather than what was
  /// sent: the server re-runs the allocation split on each save, so the response is the only
  /// account of what a transaction now looks like.
  TransactionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionsControllerHash();

  @$internal
  @override
  TransactionsController create() => TransactionsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<AsyncValue<void>>(value));
  }
}

String _$transactionsControllerHash() => r'684e2fcfec358b2f01f0a8cc8dc555cd96fa1a24';

/// Writing transactions. Every write renders the transaction that came back rather than what was
/// sent: the server re-runs the allocation split on each save, so the response is the only
/// account of what a transaction now looks like.

abstract class _$TransactionsController extends $Notifier<AsyncValue<void>> {
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
