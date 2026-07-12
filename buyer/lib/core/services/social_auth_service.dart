import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialLoginResult {
  final bool success;
  final bool cancelled;
  final String? email;
  final String? displayName;
  final String? errorMessage;

  const SocialLoginResult._({
    required this.success,
    required this.cancelled,
    this.email,
    this.displayName,
    this.errorMessage,
  });

  factory SocialLoginResult.success(
          {String? email, String? displayName}) =>
      SocialLoginResult._(
        success: true,
        cancelled: false,
        email: email,
        displayName: displayName,
      );

  factory SocialLoginResult.cancelled() => const SocialLoginResult._(
        success: false,
        cancelled: true,
      );

  factory SocialLoginResult.failure(String message) =>
      SocialLoginResult._(success: false, cancelled: false, errorMessage: message);
}

class SocialAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<SocialLoginResult> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return SocialLoginResult.cancelled();
      }
      return SocialLoginResult.success(
        email: account.email,
        displayName: account.displayName,
      );
    } catch (e) {
      return SocialLoginResult.failure('Google sign-in failed: $e');
    }
  }

  Future<void> signOutGoogle() async {
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
  }

  Future<SocialLoginResult> signInWithApple() async {
    try {
      if (!(await SignInWithApple.isAvailable())) {
        return SocialLoginResult.failure('Sign in with Apple is not available on this device');
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final displayName = [
        credential.givenName,
        credential.familyName,
      ].where((element) => element != null && element.isNotEmpty).join(' ');

      return SocialLoginResult.success(
        email: credential.email,
        displayName: displayName.isEmpty ? null : displayName,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return SocialLoginResult.cancelled();
      }
      return SocialLoginResult.failure('Apple sign-in failed: ${e.message}');
    } catch (e) {
      if (kIsWeb || !Platform.isIOS) {
        return SocialLoginResult.failure('Apple sign-in is only available on supported Apple devices');
      }
      return SocialLoginResult.failure('Apple sign-in failed: $e');
    }
  }
}

