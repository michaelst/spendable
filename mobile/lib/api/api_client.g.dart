// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(api)
final apiProvider = ApiProvider._();

final class ApiProvider
    extends $FunctionalProvider<SpendableApi, SpendableApi, SpendableApi>
    with $Provider<SpendableApi> {
  ApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiHash();

  @$internal
  @override
  $ProviderElement<SpendableApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SpendableApi create(Ref ref) {
    return api(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpendableApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpendableApi>(value),
    );
  }
}

String _$apiHash() => r'eb825fecb85ef152bd4ec030fe9772473d9f0867';
