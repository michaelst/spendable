import 'dart:async';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_channel.g.dart';

/// What the device has to say about push.
sealed class PushEvent {
  const PushEvent();
}

/// iOS issued a device token. It arrives after [PushChannel.register] and again whenever iOS
/// reissues one, so it is an event rather than the return of the call that asked for it.
class PushToken extends PushEvent {
  const PushToken(this.token);

  final String token;
}

/// A silent push: a sync finished and whatever is on screen is now behind.
class PushRefresh extends PushEvent {
  const PushRefresh();
}

/// The user tapped a notification.
class PushOpened extends PushEvent {
  const PushOpened();
}

/// Permission, registration, and the events that follow. An interface so tests do not need a
/// platform channel.
abstract interface class PushChannel {
  Stream<PushEvent> get events;

  /// Asks for permission and registers with APNs either way - a silent push needs no permission.
  /// Answers whether the user allowed alerts.
  Future<bool> register();
}

class PlatformPushChannel implements PushChannel {
  PlatformPushChannel([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('spendable/push') {
    _channel.setMethodCallHandler(_receive);
  }

  final MethodChannel _channel;
  final _events = StreamController<PushEvent>.broadcast();

  @override
  Stream<PushEvent> get events => _events.stream;

  @override
  Future<bool> register() async => await _channel.invokeMethod<bool>('register') ?? false;

  Future<void> _receive(MethodCall call) async {
    switch (call.method) {
      case 'token':
        _events.add(PushToken(call.arguments as String));
      case 'refresh':
        _events.add(const PushRefresh());
      case 'opened':
        _events.add(const PushOpened());
    }
  }
}

@Riverpod(keepAlive: true)
PushChannel pushChannel(Ref ref) => PlatformPushChannel();

@Riverpod(keepAlive: true)
Stream<PushEvent> pushEvents(Ref ref) => ref.watch(pushChannelProvider).events;
