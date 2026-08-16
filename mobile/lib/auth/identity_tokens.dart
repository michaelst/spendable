import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:spendable_api/spendable_api.dart';

part 'identity_tokens.g.dart';

/// The two ways in.
enum AuthProvider {
  apple(SessionRequestProviderEnum.apple, 'Sign in with Apple'),
  google(SessionRequestProviderEnum.google, 'Continue with Google');

  const AuthProvider(this.wire, this.label);

  final SessionRequestProviderEnum wire;
  final String label;
}

/// Runs the native sheet and hands back a provider ID token, or null if the user backed out.
/// Behind an interface so widget tests can drive sign-in without a platform channel.
abstract class IdentityTokens {
  Future<String?> fetch(AuthProvider provider);
}

class PlatformIdentityTokens implements IdentityTokens {
  // The Google iOS OAuth client id is a public identifier, not a secret. Info.plist also needs
  // its reversed form as a URL scheme - see README.md.
  static const _googleClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  var _googleInitialized = false;

  @override
  Future<String?> fetch(AuthProvider provider) => switch (provider) {
    AuthProvider.apple => _apple(),
    AuthProvider.google => _google(),
  };

  Future<String?> _apple() async {
    try {
      // No scopes: Apple only returns the name and email on first authorization, and Spendable
      // stores neither. A second provider is attached by linking, not by matching an email.
      final credential = await SignInWithApple.getAppleIDCredential(scopes: []);

      return credential.identityToken;
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) return null;

      rethrow;
    }
  }

  Future<String?> _google() async {
    try {
      if (!_googleInitialized) {
        await GoogleSignIn.instance.initialize(clientId: _googleClientId.isEmpty ? null : _googleClientId);

        _googleInitialized = true;
      }

      final account = await GoogleSignIn.instance.authenticate();

      return account.authentication.idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;

      rethrow;
    }
  }
}

@Riverpod(keepAlive: true)
IdentityTokens identityTokens(Ref ref) => PlatformIdentityTokens();
