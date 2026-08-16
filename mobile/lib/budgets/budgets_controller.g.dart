// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budgets_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Writing budgets. Every write re-reads the summary rather than patching the list: changing one
/// budget's allocation moves what is left on Spendable, so the row that came back is not the only
/// one that changed.

@ProviderFor(BudgetsController)
final budgetsControllerProvider = BudgetsControllerProvider._();

/// Writing budgets. Every write re-reads the summary rather than patching the list: changing one
/// budget's allocation moves what is left on Spendable, so the row that came back is not the only
/// one that changed.
final class BudgetsControllerProvider
    extends $NotifierProvider<BudgetsController, AsyncValue<void>> {
  /// Writing budgets. Every write re-reads the summary rather than patching the list: changing one
  /// budget's allocation moves what is left on Spendable, so the row that came back is not the only
  /// one that changed.
  BudgetsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetsControllerHash();

  @$internal
  @override
  BudgetsController create() => BudgetsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$budgetsControllerHash() => r'6671da06601d978aee7ee7eb9c1c922ffb07d5a9';

/// Writing budgets. Every write re-reads the summary rather than patching the list: changing one
/// budget's allocation moves what is left on Spendable, so the row that came back is not the only
/// one that changed.

abstract class _$BudgetsController extends $Notifier<AsyncValue<void>> {
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
