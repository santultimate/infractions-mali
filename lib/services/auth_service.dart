import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  // Dependency injection for testability
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  /// Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e, stackTrace) {
      debugPrint('Google Sign-In Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      rethrow;
    }
  }

  /// Facebook Sign-In
  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login();
      if (result.status != LoginStatus.success) return null;

      final OAuthCredential credential = 
          FacebookAuthProvider.credential(result.accessToken!.token);

      return await _auth.signInWithCredential(credential);
    } catch (e, stackTrace) {
      debugPrint('Facebook Sign-In Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      rethrow;
    }
  }

  /// Email/Password Sign-In
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Email Sign-In Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Email/Password Registration
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Registration Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut(),
      ]);
    } catch (e, stackTrace) {
      debugPrint('Sign Out Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      rethrow;
    }
  }

  /// Current User
  User? get currentUser => _auth.currentUser;

  /// Email Verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e, stackTrace) {
      debugPrint('Email Verification Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      rethrow;
    }
  }

  /// Check Email Verification (with reload)
  Future<bool> checkEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        return user.emailVerified;
      }
      return false;
    } catch (e, stackTrace) {
      debugPrint('Email Check Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      return false;
    }
  }

  /// Quick Email Verification Check
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// User Changes Stream
  Stream<User?> get userChanges => _auth.userChanges();

  /// Additional Security Methods
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e, stackTrace) {
      debugPrint('Password Update Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e, stackTrace) {
      debugPrint('Password Reset Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      rethrow;
    }
  }
}