import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final LocalAuthentication _localAuth = LocalAuthentication();

  FirebaseAuth? get _auth {
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint("Firebase Auth unavailable: $e");
      return null;
    }
  }

  // Authentication State
  Stream<User?> get user => _auth?.authStateChanges() ?? Stream.value(null);

  bool get hasFirebase => _auth != null;

  Future<bool> signInEmailOrLocal(String email, String password) async {
    final auth = _auth;
    if (auth != null) {
      try {
        final credential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        await _ensureUserDocument(credential.user);
        return true;
      } catch (e) {
        debugPrint("Email Sign-In Error: $e");
        return false;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('local_user_email');
    final savedPassword = prefs.getString('local_user_password');
    final ok = savedEmail == email && savedPassword == password;
    if (ok) await prefs.setBool('local_signed_in', true);
    return ok;
  }

  Future<bool> signUpEmailOrLocal(
    String email,
    String password, {
    String? name,
  }) async {
    final auth = _auth;
    if (auth != null) {
      try {
        final credential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (name != null && name.trim().isNotEmpty) {
          await credential.user?.updateDisplayName(name.trim());
        }
        await _ensureUserDocument(credential.user);
        return true;
      } catch (e) {
        debugPrint("Email Sign-Up Error: $e");
        return false;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_user_name', name?.trim() ?? 'Nabil');
    await prefs.setString('local_user_email', email);
    await prefs.setString('local_user_password', password);
    await prefs.setBool('local_signed_in', true);
    return true;
  }

  Future<bool> signInGoogleOrLocal() async {
    final auth = _auth;
    if (auth != null) {
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return false;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await auth.signInWithCredential(credential);
        await _ensureUserDocument(userCredential.user);
        return true;
      } catch (e) {
        debugPrint("Google Sign-In Error: $e");
        return false;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_user_name', 'Google User');
    await prefs.setString('local_user_email', 'google.local@pocketsense.app');
    await prefs.setBool('local_signed_in', true);
    return true;
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    final auth = _auth;
    if (auth == null) return null;

    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint("Email Sign-In Error: $e");
      return null;
    }
  }

  Future<UserCredential?> signUpWithEmail(
    String email,
    String password, {
    String? name,
  }) async {
    final auth = _auth;
    if (auth == null) return null;

    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (name != null && name.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(name.trim());
      }
      await _ensureUserDocument(credential.user);
      return credential;
    } catch (e) {
      debugPrint("Email Sign-Up Error: $e");
      return null;
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) return null;

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await auth.signInWithCredential(credential);
      await _ensureUserDocument(userCredential.user);
      return userCredential;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth?.signOut();
  }

  Future<bool> sendPasswordReset(String email) async {
    final auth = _auth;
    if (auth == null || email.trim().isEmpty) return false;
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      debugPrint("Password reset error: $e");
      return false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    final user = _auth?.currentUser;
    if (user == null || newPassword.length < 6) return false;
    try {
      await user.updatePassword(newPassword);
      return true;
    } catch (e) {
      debugPrint("Password change error: $e");
      return false;
    }
  }

  Future<void> _ensureUserDocument(User? user) async {
    if (user == null || Firebase.apps.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'currency': 'BDT',
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("User document error: $e");
    }
  }

  // Security: Biometric Auth (Fingerprint/FaceID)
  Future<bool> authenticate() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) return true; // Fallback if not supported

      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access Pocket Sense',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      debugPrint("Biometric Auth Error: $e");
      return false;
    }
  }
}
