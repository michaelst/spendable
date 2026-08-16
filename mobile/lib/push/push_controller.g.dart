// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Registers the device once there is a session to attach it to, and acts on what arrives.
/// Nothing renders it; it is watched from the root so it is alive whichever screen the user is on.

@ProviderFor(pushController)
final pushControllerProvider = PushControllerProvider._();

/// Registers the device once there is a session to attach it to, and acts on what arrives.
/// Nothing renders it; it is watched from the root so it is alive whichever screen the user is on.

final class PushControllerProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Registers the device once there is a session to attach it to, and acts on what arrives.
  /// Nothing renders it; it is watched from the root so it is alive whichever screen the user is on.
  PushControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushControllerHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return pushController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$pushControllerHash() => r'c46cc5070ec2f21da058d1ede37880a365834de1';
