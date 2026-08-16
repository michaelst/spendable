// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_tab.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Which tab the shell is showing. A provider rather than the shell's own state because a tapped
/// notification has to be able to move it.

@ProviderFor(SelectedTab)
final selectedTabProvider = SelectedTabProvider._();

/// Which tab the shell is showing. A provider rather than the shell's own state because a tapped
/// notification has to be able to move it.
final class SelectedTabProvider extends $NotifierProvider<SelectedTab, AppTab> {
  /// Which tab the shell is showing. A provider rather than the shell's own state because a tapped
  /// notification has to be able to move it.
  SelectedTabProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedTabProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedTabHash();

  @$internal
  @override
  SelectedTab create() => SelectedTab();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppTab value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppTab>(value),
    );
  }
}

String _$selectedTabHash() => r'7e06ca85e5b9ca9306cd25dba26520a14962b0ba';

/// Which tab the shell is showing. A provider rather than the shell's own state because a tapped
/// notification has to be able to move it.

abstract class _$SelectedTab extends $Notifier<AppTab> {
  AppTab build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppTab, AppTab>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppTab, AppTab>,
              AppTab,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
