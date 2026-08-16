import 'dart:async';

import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plaid_link_flow.g.dart';

/// Runs Plaid Link and hands back the public token, or null if the user backed out. Behind an
/// interface because PlaidLink is a set of static methods over a platform channel.
abstract interface class PlaidLinkFlow {
  Future<String?> open(String linkToken);
}

class PlatformPlaidLinkFlow implements PlaidLinkFlow {
  @override
  Future<String?> open(String linkToken) async {
    final result = Completer<String?>();

    // Whichever fires first ends the session; the other stream never fires for it.
    final success = PlaidLink.onSuccess.listen((event) {
      if (!result.isCompleted) result.complete(event.publicToken);
    });

    final exit = PlaidLink.onExit.listen((_) {
      if (!result.isCompleted) result.complete(null);
    });

    try {
      await PlaidLink.create(configuration: LinkTokenConfiguration(token: linkToken));
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
