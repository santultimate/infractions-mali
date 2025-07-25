import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔐 Connexion avec Google
  Future<UserCredential?> signInWithGoogle() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) return null; // L'utilisateur a annulé la connexion

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    print('Erreur Google Sign-In: $e');
    return null;
  }

}


  // 🔐 Connexion avec Facebook
  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status != LoginStatus.success) return null;

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(result.accessToken!.token);

      return await _auth.signInWithCredential(facebookAuthCredential);
    } catch (e) {
      print('Erreur Facebook Sign-In: $e');
      return null;
    }
  }

  // 📧 Connexion avec email et mot de passe
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print('Erreur login email: $e');
      return null;
    }
  }

  // 🆕 Inscription avec email et mot de passe
  Future<UserCredential?> registerWithEmail(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print('Erreur inscription: $e');
      return null;
    }
  }

  // 🚪 Déconnexion de tous les fournisseurs
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();
    } catch (e) {
      print('Erreur déconnexion: $e');
    }
  }

  // 👤 Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // 📩 Envoyer un email de vérification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      print('Erreur envoi email vérification: $e');
    }
  }

  // ✅ Vérifier si l'email est vérifié (avec reload)
  Future<bool> checkEmailVerification() async {
    try {
      final user = _auth.currentUser;
      await user?.reload();
      return user?.emailVerified ?? false;
    } catch (e) {
      print('Erreur vérification email: $e');
      return false;
    }
  }

  // ✅ Getter rapide (non reloadé)
  bool get isEmailVerified {
    final user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  // 🔄 Écouter les changements d'état utilisateur
  Stream<User?> get userChanges => _auth.userChanges();
}

