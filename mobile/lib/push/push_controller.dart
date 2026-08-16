import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_client.dart';
import '../auth/auth_controller.dart';
import '../banks/banks_providers.dart';
import '../budgets/budgets_providers.dart';
import '../selected_tab.dart';
import '../transactions/transactions_providers.dart';
import 'push_channel.dart';

part 'push_controller.g.dart';

/// Registers the device once there is a session to attach it to, and acts on what arrives.
/// Nothing renders it; it is watched from the root so it is alive whichever screen the user is on.
@Riverpod(keepAlive: true)
void pushController(Ref ref) {
  // Registering only while signed in: the device token is held against the API token, so there is
  // nowhere to put it until sign-in has produced one.
  ref.listen(authStateProvider, (_, next) {
    if (next case AsyncData(value: true)) ref.read(pushChannelProvider).register();
  }, fireImmediately: true);

  ref.listen(pushEventsProvider, (_, next) {
    if (next case AsyncData(value: final event)) {
      switch (event) {
        case PushToken(:final token):
          _register(ref, token);
        case PushRefresh():
          _refresh(ref);
        case PushOpened():
          ref.read(selectedTabProvider.notifier).select(AppTab.transactions);
          _refresh(ref);
      }
    }
  });
}

/// A failure here is not worth surfacing: the user asked for nothing, and the next launch tries
/// again with whatever token iOS hands over then.
Future<void> _register(Ref ref, String token) async {
  if (ref.read(authStateProvider).value != true) return;

  final request = SessionUpdateRequest((builder) => builder.apnsToken = token);

  try {
    await ref.read(apiProvider).getSessionApi().updateSession(sessionUpdateRequest: request);
  } on DioException {
    // Nothing to tell the user: they asked for nothing, and the next launch registers again.
  }
}

/// A sync landed on the server, so everything read from it is now behind. Invalidating rather
/// than patching keeps to the rule that the server is the only account of what things look like.
void _refresh(Ref ref) {
  ref.invalidate(transactionsProvider);
  ref.invalidate(budgetSummaryProvider);
  ref.invalidate(bankMembersProvider);
}
