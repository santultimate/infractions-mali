import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth? _auth;
  final GoogleSignIn? _googleSignIn;
  final FacebookAuth? _facebookAuth;

  // Dependency injection for testability
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  })  : _auth = auth,
        _googleSignIn = googleSignIn,
        _facebookAuth = facebookAuth;

  /// Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    if (_auth == null || _googleSignIn == null) {
      debugPrint('Firebase Auth or Google Sign-In not available');
      return null;
    }

    try {
      // Check if user is already signed in
      if (await _googleSignIn!.isSignedIn()) {
        await _googleSignIn!.signOut();
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        debugPrint('Google Sign-In cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw FirebaseAuthException(
          code: 'google_auth_failed',
          message: 'Failed to get Google authentication tokens',
        );
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth!.signInWithCredential(credential);

      // Send email verification if needed
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Google Sign-In Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('Google Sign-In Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      throw FirebaseAuthException(
        code: 'google_signin_failed',
        message: 'Google Sign-In failed: $e',
      );
    }
  }

  /// Facebook Sign-In
  Future<UserCredential?> signInWithFacebook() async {
    if (_auth == null || _facebookAuth == null) {
      debugPrint('Firebase Auth or Facebook Auth not available');
      return null;
    }

    try {
      final LoginResult result = await _facebookAuth!.login();

      if (result.status != LoginStatus.success) {
        debugPrint('Facebook Sign-In failed: ${result.status}');
        if (result.status == LoginStatus.cancelled) {
          return null;
        }
        throw FirebaseAuthException(
          code: 'facebook_auth_failed',
          message: 'Facebook authentication failed: ${result.status}',
        );
      }

      if (result.accessToken == null) {
        throw FirebaseAuthException(
          code: 'facebook_token_missing',
          message: 'Facebook access token is missing',
        );
      }

      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);

      final userCredential = await _auth!.signInWithCredential(credential);

      // Send email verification if needed
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Facebook Sign-In Firebase Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('Facebook Sign-In Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      throw FirebaseAuthException(
        code: 'facebook_signin_failed',
        message: 'Facebook Sign-In failed: $e',
      );
    }
  }

  /// Email/Password Sign-In
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (email.trim().isEmpty || password.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid_email_or_password',
          message: 'Email and password cannot be empty',
        );
      }

      if (_auth == null) {
        throw FirebaseAuthException(
          code: 'auth_not_available',
          message: 'Firebase Auth not available',
        );
      }

      return await _auth!.signInWithEmailAndPassword(
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
    String? displayName,
  }) async {
    try {
      if (email.trim().isEmpty || password.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid_email_or_password',
          message: 'Email and password cannot be empty',
        );
      }

      if (password.length < 6) {
        throw FirebaseAuthException(
          code: 'weak_password',
          message: 'Password must be at least 6 characters long',
        );
      }

      if (_auth == null) {
        throw FirebaseAuthException(
          code: 'auth_not_available',
          message: 'Firebase Auth not available',
        );
      }

      final userCredential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName);
      }

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Registration Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      final futures = <Future<void>>[];
      if (_auth != null) futures.add(_auth!.signOut());
      if (_googleSignIn != null) futures.add(_googleSignIn!.signOut());
      if (_facebookAuth != null) futures.add(_facebookAuth!.logOut());

      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }
      debugPrint('User signed out successfully');
    } catch (e, stackTrace) {
      debugPrint('Sign Out Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      rethrow;
    }
  }

  /// Current User
  User? get currentUser => _auth?.currentUser;

  /// Email Verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth?.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        debugPrint('Email verification sent successfully');
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
      final user = _auth?.currentUser;
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
  bool get isEmailVerified => _auth?.currentUser?.emailVerified ?? false;

  /// User Changes Stream
  Stream<User?> get userChanges => _auth?.userChanges() ?? Stream.value(null);

  /// Additional Security Methods
  Future<void> updatePassword(String newPassword) async {
    try {
      if (newPassword.length < 6) {
        throw FirebaseAuthException(
          code: 'weak_password',
          message: 'Password must be at least 6 characters long',
        );
      }

      await _auth?.currentUser?.updatePassword(newPassword);
      debugPrint('Password updated successfully');
    } catch (e, stackTrace) {
      debugPrint('Password Update Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (email.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid_email',
          message: 'Email cannot be empty',
        );
      }

      if (_auth == null) {
        throw FirebaseAuthException(
          code: 'auth_not_available',
          message: 'Firebase Auth not available',
        );
      }
      await _auth!.sendPasswordResetEmail(email: email.trim());
      debugPrint('Password reset email sent successfully');
    } catch (e, stackTrace) {
      debugPrint('Password Reset Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      rethrow;
    }
  }

  /// Get User Display Name
  String? get userDisplayName => _auth?.currentUser?.displayName;

  /// Get User Email
  String? get userEmail => _auth?.currentUser?.email;

  /// Get User Photo URL
  String? get userPhotoURL => _auth?.currentUser?.photoURL;

  /// Check if user is logged in
  bool get isLoggedIn => _auth?.currentUser != null;

  /// Get User ID
  String? get userId => _auth?.currentUser?.uid;

  /// Check if user is anonymous
  bool get isAnonymous => _auth?.currentUser?.isAnonymous ?? false;

  /// Get user creation time
  DateTime? get userCreationTime => _auth?.currentUser?.metadata.creationTime;

  /// Get last sign in time
  DateTime? get lastSignInTime => _auth?.currentUser?.metadata.lastSignInTime;

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      await _auth?.currentUser?.delete();
      debugPrint('User account deleted successfully');
    } catch (e, stackTrace) {
      debugPrint('Delete Account Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _auth?.currentUser?.updateDisplayName(displayName);
      await _auth?.currentUser?.updatePhotoURL(photoURL);
      debugPrint('User profile updated successfully');
    } catch (e, stackTrace) {
      debugPrint('Update Profile Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      rethrow;
    }
  }
}
