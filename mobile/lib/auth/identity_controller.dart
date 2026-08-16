import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';
import 'current_user.dart';
import 'identity_tokens.dart';

part 'identity_controller.g.dart';

/// Attaching and removing ways of signing in. Linking is an authenticated action rather than
/// something inferred from a shared email, because Spendable stores no email to match on.
@riverpod
class IdentityController extends _$IdentityController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> link(AuthProvider provider) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final idToken = await ref.read(identityTokensProvider).fetch(provider);

      if (idToken == null) return;

      final request = SessionRequest(
        (builder) => builder
          ..provider = provider.wire
          ..idToken = idToken,
      );

      await ref.read(apiProvider).getSessionApi().createIdentity(sessionRequest: request).orApiError();

      ref.invalidate(currentUserProvider);
    });
  }

  Future<void> unlink(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(apiProvider).getSessionApi().deleteIdentity(id: id).orApiError();

      ref.invalidate(currentUserProvider);
    });
  }
}
