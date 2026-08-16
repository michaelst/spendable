// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_channel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pushChannel)
final pushChannelProvider = PushChannelProvider._();

final class PushChannelProvider
    extends $FunctionalProvider<PushChannel, PushChannel, PushChannel>
    with $Provider<PushChannel> {
  PushChannelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushChannelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushChannelHash();

  @$internal
  @override
  $ProviderElement<PushChannel> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PushChannel create(Ref ref) {
    return pushChannel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushChannel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushChannel>(value),
    );
  }
}

String _$pushChannelHash() => r'c177d822753fafe7f8119849877e1362fb222133';

@ProviderFor(pushEvents)
final pushEventsProvider = PushEventsProvider._();

final class PushEventsProvider
    extends
        $FunctionalProvider<AsyncValue<PushEvent>, PushEvent, Stream<PushEvent>>
    with $FutureModifier<PushEvent>, $StreamProvider<PushEvent> {
  PushEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushEventsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushEventsHash();

  @$internal
  @override
  $StreamProviderElement<PushEvent> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<PushEvent> create(Ref ref) {
    return pushEvents(ref);
  }
}

String _$pushEventsHash() => r'21daab61587463f4d6b1f16d8a9edcad723d0803';
