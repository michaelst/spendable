// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plaid_link_flow.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(plaidLinkFlow)
final plaidLinkFlowProvider = PlaidLinkFlowProvider._();

final class PlaidLinkFlowProvider
    extends $FunctionalProvider<PlaidLinkFlow, PlaidLinkFlow, PlaidLinkFlow>
    with $Provider<PlaidLinkFlow> {
  PlaidLinkFlowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plaidLinkFlowProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plaidLinkFlowHash();

  @$internal
  @override
  $ProviderElement<PlaidLinkFlow> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlaidLinkFlow create(Ref ref) {
    return plaidLinkFlow(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaidLinkFlow value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaidLinkFlow>(value),
    );
  }
}

String _$plaidLinkFlowHash() => r'2ced55febcf80f4bd54577a98eeaf999beec9286';
