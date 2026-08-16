// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banks_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bankMembers)
final bankMembersProvider = BankMembersProvider._();

final class BankMembersProvider
    extends $FunctionalProvider<AsyncValue<List<BankMember>>, List<BankMember>, FutureOr<List<BankMember>>>
    with $FutureModifier<List<BankMember>>, $FutureProvider<List<BankMember>> {
  BankMembersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bankMembersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bankMembersHash();

  @$internal
  @override
  $FutureProviderElement<List<BankMember>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<BankMember>> create(Ref ref) {
    return bankMembers(ref);
  }
}

String _$bankMembersHash() => r'f30552862d0a1b3d4eb9c7d6185e5998ba71b9ce';

/// Logos come down the authenticated API rather than a public URL, so they are fetched through
/// the same client and held per member instead of by an image cache.

@ProviderFor(bankLogo)
final bankLogoProvider = BankLogoFamily._();

/// Logos come down the authenticated API rather than a public URL, so they are fetched through
/// the same client and held per member instead of by an image cache.

final class BankLogoProvider
    extends $FunctionalProvider<AsyncValue<Uint8List>, Uint8List, FutureOr<Uint8List>>
    with $FutureModifier<Uint8List>, $FutureProvider<Uint8List> {
  /// Logos come down the authenticated API rather than a public URL, so they are fetched through
  /// the same client and held per member instead of by an image cache.
  BankLogoProvider._({required BankLogoFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'bankLogoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bankLogoHash();

  @override
  String toString() {
    return r'bankLogoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List> create(Ref ref) {
    final argument = this.argument as String;
    return bankLogo(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BankLogoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bankLogoHash() => r'38aa22032bc1b610fa9d253aeab30c015aba8a83';

/// Logos come down the authenticated API rather than a public URL, so they are fetched through
/// the same client and held per member instead of by an image cache.

final class BankLogoFamily extends $Family with $FunctionalFamilyOverride<FutureOr<Uint8List>, String> {
  BankLogoFamily._()
    : super(
        retry: null,
        name: r'bankLogoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Logos come down the authenticated API rather than a public URL, so they are fetched through
  /// the same client and held per member instead of by an image cache.

  BankLogoProvider call(String memberId) => BankLogoProvider._(argument: memberId, from: this);

  @override
  String toString() => r'bankLogoProvider';
}
