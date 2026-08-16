// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budgets_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Null leaves the choice to the server, which answers for the current month.

@ProviderFor(SelectedMonth)
final selectedMonthProvider = SelectedMonthProvider._();

/// Null leaves the choice to the server, which answers for the current month.
final class SelectedMonthProvider extends $NotifierProvider<SelectedMonth, Date?> {
  /// Null leaves the choice to the server, which answers for the current month.
  SelectedMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedMonthHash();

  @$internal
  @override
  SelectedMonth create() => SelectedMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Date? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Date?>(value));
  }
}

String _$selectedMonthHash() => r'aab73e649f6bc3b895dc03ad2ff7354ee2298cd9';

/// Null leaves the choice to the server, which answers for the current month.

abstract class _$SelectedMonth extends $Notifier<Date?> {
  Date? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Date?, Date?>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<Date?, Date?>, Date?, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(BudgetSearch)
final budgetSearchProvider = BudgetSearchProvider._();

final class BudgetSearchProvider extends $NotifierProvider<BudgetSearch, String?> {
  BudgetSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetSearchHash();

  @$internal
  @override
  BudgetSearch create() => BudgetSearch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<String?>(value));
  }
}

String _$budgetSearchHash() => r'b0b421d77d5fccbd97674c766dcba50a9b30957a';

abstract class _$BudgetSearch extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<String?, String?>, String?, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(budgetSummary)
final budgetSummaryProvider = BudgetSummaryProvider._();

final class BudgetSummaryProvider
    extends $FunctionalProvider<AsyncValue<BudgetSummary>, BudgetSummary, FutureOr<BudgetSummary>>
    with $FutureModifier<BudgetSummary>, $FutureProvider<BudgetSummary> {
  BudgetSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetSummaryHash();

  @$internal
  @override
  $FutureProviderElement<BudgetSummary> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<BudgetSummary> create(Ref ref) {
    return budgetSummary(ref);
  }
}

String _$budgetSummaryHash() => r'1605faaf2008480baa76429a5292bbcccd393c08';

/// The budget picker every other screen offers.

@ProviderFor(budgetOptions)
final budgetOptionsProvider = BudgetOptionsProvider._();

/// The budget picker every other screen offers.

final class BudgetOptionsProvider
    extends $FunctionalProvider<AsyncValue<List<Budget>>, List<Budget>, FutureOr<List<Budget>>>
    with $FutureModifier<List<Budget>>, $FutureProvider<List<Budget>> {
  /// The budget picker every other screen offers.
  BudgetOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetOptionsHash();

  @$internal
  @override
  $FutureProviderElement<List<Budget>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Budget>> create(Ref ref) {
    return budgetOptions(ref);
  }
}

String _$budgetOptionsHash() => r'064a5f67d9ec443f9f5436be2ef8d35721a31d60';
