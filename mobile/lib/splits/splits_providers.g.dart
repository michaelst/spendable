// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splits_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(splits)
final splitsProvider = SplitsProvider._();

final class SplitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Split>>,
          List<Split>,
          FutureOr<List<Split>>
        >
    with $FutureModifier<List<Split>>, $FutureProvider<List<Split>> {
  SplitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splitsHash();

  @$internal
  @override
  $FutureProviderElement<List<Split>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Split>> create(Ref ref) {
    return splits(ref);
  }
}

String _$splitsHash() => r'88eea8e32b6a3b092b45352388a91742265c0fd6';

@ProviderFor(SplitSelection)
final splitSelectionProvider = SplitSelectionProvider._();

final class SplitSelectionProvider
    extends $NotifierProvider<SplitSelection, Set<String>> {
  SplitSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splitSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splitSelectionHash();

  @$internal
  @override
  SplitSelection create() => SplitSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$splitSelectionHash() => r'b6d0fbd379df83262f7ff5ae3a2bf9555367045b';

abstract class _$SplitSelection extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
