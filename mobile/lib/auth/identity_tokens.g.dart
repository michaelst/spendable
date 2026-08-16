// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_tokens.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(identityTokens)
final identityTokensProvider = IdentityTokensProvider._();

final class IdentityTokensProvider
    extends $FunctionalProvider<IdentityTokens, IdentityTokens, IdentityTokens>
    with $Provider<IdentityTokens> {
  IdentityTokensProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'identityTokensProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$identityTokensHash();

  @$internal
  @override
  $ProviderElement<IdentityTokens> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IdentityTokens create(Ref ref) {
    return identityTokens(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdentityTokens value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdentityTokens>(value),
    );
  }
}

String _$identityTokensHash() => r'91b5b7ba5fd08e58b412ae0f3d8a7f976fee18b6';
