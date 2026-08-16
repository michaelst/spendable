// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Filters)
final filtersProvider = FiltersProvider._();

final class FiltersProvider extends $NotifierProvider<Filters, TransactionFilters> {
  FiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filtersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filtersHash();

  @$internal
  @override
  Filters create() => Filters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionFilters value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<TransactionFilters>(value));
  }
}

String _$filtersHash() => r'16133d52d4b6a5afc6c00a3be3d3f118f47646b8';

abstract class _$Filters extends $Notifier<TransactionFilters> {
  TransactionFilters build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TransactionFilters, TransactionFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TransactionFilters, TransactionFilters>,
              TransactionFilters,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Pages append rather than replace. A page shorter than what was asked for is the last one.

@ProviderFor(Transactions)
final transactionsProvider = TransactionsProvider._();

/// Pages append rather than replace. A page shorter than what was asked for is the last one.
final class TransactionsProvider extends $AsyncNotifierProvider<Transactions, TransactionPage> {
  /// Pages append rather than replace. A page shorter than what was asked for is the last one.
  TransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionsHash();

  @$internal
  @override
  Transactions create() => Transactions();
}

String _$transactionsHash() => r'764fa574c14011b86d9f7a4029be58b7c59a3b58';

/// Pages append rather than replace. A page shorter than what was asked for is the last one.

abstract class _$Transactions extends $AsyncNotifier<TransactionPage> {
  FutureOr<TransactionPage> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TransactionPage>, TransactionPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TransactionPage>, TransactionPage>,
              AsyncValue<TransactionPage>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Selection)
final selectionProvider = SelectionProvider._();

final class SelectionProvider extends $NotifierProvider<Selection, Set<String>> {
  SelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectionHash();

  @$internal
  @override
  Selection create() => Selection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Set<String>>(value));
  }
}

String _$selectionHash() => r'ac4009fb7f720fec495e12ce689e9a655c332d23';

abstract class _$Selection extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<Set<String>, Set<String>>, Set<String>, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
