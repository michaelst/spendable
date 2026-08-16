// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plaid_oauth_links.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Universal links the app is opened with. The first one is included, which is the case that
/// matters here - the app was not running when the bank redirected.

@ProviderFor(incomingLinks)
final incomingLinksProvider = IncomingLinksProvider._();

/// Universal links the app is opened with. The first one is included, which is the case that
/// matters here - the app was not running when the bank redirected.

final class IncomingLinksProvider
    extends $FunctionalProvider<AsyncValue<Uri>, Uri, Stream<Uri>>
    with $FutureModifier<Uri>, $StreamProvider<Uri> {
  /// Universal links the app is opened with. The first one is included, which is the case that
  /// matters here - the app was not running when the bank redirected.
  IncomingLinksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomingLinksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomingLinksHash();

  @$internal
  @override
  $StreamProviderElement<Uri> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Uri> create(Ref ref) {
    return incomingLinks(ref);
  }
}

String _$incomingLinksHash() => r'd9c4f72d209beb8c9af9253cf60de9194c41bf84';

/// Finishes a bank connection the user started before iOS terminated the app on them. Watched
/// from the root so it is listening whichever screen they land on.

@ProviderFor(plaidOAuthResume)
final plaidOAuthResumeProvider = PlaidOAuthResumeProvider._();

/// Finishes a bank connection the user started before iOS terminated the app on them. Watched
/// from the root so it is listening whichever screen they land on.

final class PlaidOAuthResumeProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Finishes a bank connection the user started before iOS terminated the app on them. Watched
  /// from the root so it is listening whichever screen they land on.
  PlaidOAuthResumeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plaidOAuthResumeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plaidOAuthResumeHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return plaidOAuthResume(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$plaidOAuthResumeHash() => r'579f2c8195eb67be560204a57be0ffd5e1be1cfd';
