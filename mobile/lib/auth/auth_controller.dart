import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';
import 'identity_tokens.dart';
import 'token_storage.dart';

part 'auth_controller.g.dart';

/// Labels the token row so the account screen can tell one device from another.
@Riverpod(keepAlive: true)
Future<String?> deviceName(Ref ref) async => (await DeviceInfoPlugin().iosInfo).name;

/// Whether a token is held, and nothing else - everything about the account itself comes from
/// `GET /api/me`. Kept apart from [AuthController] so a sign-in attempt in flight never leaves
/// the app unsure which screen it is on.
@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  Future<bool> build() async => await ref.read(tokenStorageProvider).read() != null;

  void signedIn() => state = const AsyncData(true);

  void signedOut() => state = const AsyncData(false);

  /// The server rejected the stored token, so drop it without trying to revoke it again.
  Future<void> sessionExpired() async {
    await ref.read(tokenStorageProvider).clear();

    signedOut();
  }
}

/// Signing in and out. Its own state is the progress and failure of the attempt.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  // Synchronous so the buttons are live on the first frame; the state tracks the attempt, not
  // any state of its own to load.
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signIn(AuthProvider provider) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final idToken = await ref.read(identityTokensProvider).fetch(provider);

      // The user backed out of the native sheet, which is not a failure to report.
      if (idToken == null) return;

      final device = await ref.read(deviceNameProvider.future);

      final request = SessionRequest(
        (builder) => builder
          ..provider = provider.wire
          ..idToken = idToken
          ..deviceName = device,
      );

      final response = await ref
          .read(apiProvider)
          .getSessionApi()
          .createSession(sessionRequest: request)
          .orApiError();

      await ref.read(tokenStorageProvider).write(response.data!.token);

      ref.read(authStateProvider.notifier).signedIn();
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        await ref.read(apiProvider).getSessionApi().deleteSession();
      } on DioException {
        // The row may already be gone, and the app cannot stay signed in either way.
      }

      await ref.read(tokenStorageProvider).clear();

      ref.read(authStateProvider.notifier).signedOut();
    });
  }
}
