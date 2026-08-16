import 'dart:async';

import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plaid_link_flow.g.dart';

/// Runs Plaid Link and hands back the public token, or null if the user backed out. Behind an
/// interface because PlaidLink is a set of static methods over a platform channel.
abstract interface class PlaidLinkFlow {
  Future<String?> open(String linkToken);

  /// Picks a session back up after iOS terminated the app while the user was on the bank's OAuth
  /// page. The redirect that brought the app back is the only state Link needs.
  Future<String?> resume(String redirectUri);
}

class PlatformPlaidLinkFlow implements PlaidLinkFlow {
  @override
  Future<String?> open(String linkToken) =>
      _awaiting(() => PlaidLink.create(configuration: LinkTokenConfiguration(token: linkToken)));

  @override
  Future<String?> resume(String redirectUri) =>
      _awaiting(() => PlaidLink.resumeAfterTermination(redirectUri));

  /// Both entry points end the same way: exactly one of onSuccess and onExit fires.
  Future<String?> _awaiting(Future<void> Function() start) async {
    final result = Completer<String?>();

    final success = PlaidLink.onSuccess.listen((event) {
      if (!result.isCompleted) result.complete(event.publicToken);
    });

    final exit = PlaidLink.onExit.listen((_) {
      if (!result.isCompleted) result.complete(null);
    });

    try {
      await start();
      await PlaidLink.open();

      return await result.future;
    } finally {
      await success.cancel();
      await exit.cancel();
    }
  }
}

@Riverpod(keepAlive: true)
PlaidLinkFlow plaidLinkFlow(Ref ref) => PlatformPlaidLinkFlow();
