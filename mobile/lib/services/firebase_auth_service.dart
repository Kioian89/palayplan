import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'api_service.dart';
import 'firebase_options.dart';

class FirebaseAuthService {
  FirebaseAuthService({
    required FirebaseAuth auth,
    required ApiService api,
  })  : _auth = auth,
        _api = api,
        _googleSignIn = GoogleSignIn(
          clientId: FirebaseClientOptions.googleWebClientId.isEmpty
              ? null
              : FirebaseClientOptions.googleWebClientId,
          scopes: const ['email'],
        );

  final FirebaseAuth _auth;
  final ApiService _api;
  final GoogleSignIn _googleSignIn;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _verifyWithBackend(credential.user);
  }

  Future<void> createAccount({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _verifyWithBackend(credential.user);
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    await _verifyWithBackend(userCredential.user);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> _verifyWithBackend(User? user) async {
    if (user == null) {
      throw StateError('Firebase did not return a signed-in user.');
    }

    try {
      final idToken = await user.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Firebase did not return an ID token.');
      }
      await _api.verifyFirebaseToken(idToken);
    } catch (_) {
      await _auth.signOut();
      if (!kIsWeb) await _googleSignIn.signOut();
      rethrow;
    }
  }
}
