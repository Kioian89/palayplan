import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';

class FirebaseAuthService {
  FirebaseAuthService({required FirebaseAuth auth})
    // Preserve the public `auth:` named argument while storing it privately.
    // ignore: prefer_initializing_formals
    : _auth = auth,
      _googleSignIn = GoogleSignIn(
        clientId: FirebaseClientOptions.googleWebClientId.isEmpty
            ? null
            : FirebaseClientOptions.googleWebClientId,
        scopes: const ['email'],
      );
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuth get firebaseAuth => _auth;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> createAccount({
    required String email,
    required String password,
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
