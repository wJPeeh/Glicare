import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthCancelled implements Exception {
  const AuthCancelled();
}

class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) {
      await credential.user?.updateDisplayName(trimmed);
      await credential.user?.reload();
    }
    return credential;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw const AuthCancelled();
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithFacebook() async {
    final result = await _facebookAuth.login(
      permissions: const ['email', 'public_profile'],
    );
    switch (result.status) {
      case LoginStatus.success:
        final token = result.accessToken;
        if (token == null) {
          throw FirebaseAuthException(
            code: 'facebook-no-token',
            message: 'Token do Facebook indisponível.',
          );
        }
        final credential = FacebookAuthProvider.credential(token.tokenString);
        return _firebaseAuth.signInWithCredential(credential);
      case LoginStatus.cancelled:
        throw const AuthCancelled();
      case LoginStatus.failed:
      case LoginStatus.operationInProgress:
        throw FirebaseAuthException(
          code: 'facebook-login-failed',
          message: result.message ?? 'Falha no login do Facebook.',
        );
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      await _facebookAuth.logOut();
    } catch (_) {}
    await _firebaseAuth.signOut();
  }
}
