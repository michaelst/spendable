// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_plaid_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pendingPlaidSession)
final pendingPlaidSessionProvider = PendingPlaidSessionProvider._();

final class PendingPlaidSessionProvider
    extends
        $FunctionalProvider<
          PendingPlaidSession,
          PendingPlaidSession,
          PendingPlaidSession
        >
    with $Provider<PendingPlaidSession> {
  PendingPlaidSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingPlaidSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingPlaidSessionHash();

  @$internal
  @override
  $ProviderElement<PendingPlaidSession> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PendingPlaidSession create(Ref ref) {
    return pendingPlaidSession(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PendingPlaidSession value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PendingPlaidSession>(value),
    );
  }
}

String _$pendingPlaidSessionHash() =>
    r'810a6db15cac2909ad665c5256c858a53a306ef6';
