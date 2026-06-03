import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUserProfile {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String? photoUrl;
  final DateTime createdAt;

  const AppUserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
    this.photoUrl,
  });
}

class AuthService {
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
        await _saveProfile(credential.user);
        return true;
      } catch (e) {
        debugPrint("Email Sign-In Error: $e");
        // Fallback to local
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
    String? phoneNumber,
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
        await _saveProfile(credential.user, phoneNumber: phoneNumber);
        return true;
      } catch (e) {
        debugPrint("Email Sign-Up Error: $e");
        // Fallback to local
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_user_name', name?.trim() ?? 'Nabil');
    await prefs.setString('local_user_email', email);
    await prefs.setString('profile_phone', phoneNumber?.trim() ?? '');
    await prefs.setString('local_user_password', password);
    await prefs.setString('local_user_uid', 'local-email-user');
    await prefs.setString(
      'local_user_created_at',
      prefs.getString('local_user_created_at') ??
          DateTime.now().toIso8601String(),
    );
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
    String? phoneNumber,
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
      await _saveProfile(credential.user, phoneNumber: phoneNumber);
      return credential;
    } catch (e) {
      debugPrint("Email Sign-Up Error: $e");
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth?.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('local_signed_in', false);
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

  Future<bool> isSignedIn() async {
    if (_auth?.currentUser != null) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('local_signed_in') ?? false;
  }

  Future<AppUserProfile> currentProfile() async {
    final user = _auth?.currentUser;
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      return AppUserProfile(
        uid: user.uid,
        name:
            user.displayName ??
            prefs.getString('profile_name') ??
            user.email?.split('@').first ??
            'Pocket Sense User',
        email: prefs.getString('profile_email') ?? user.email ?? '',
        phoneNumber: user.phoneNumber ?? prefs.getString('profile_phone') ?? '',
        photoUrl: user.photoURL ?? prefs.getString('profile_photo_url'),
        createdAt:
            DateTime.tryParse(prefs.getString('profile_created_at') ?? '') ??
            user.metadata.creationTime ??
            DateTime.now(),
      );
    }

    final createdAt =
        DateTime.tryParse(prefs.getString('local_user_created_at') ?? '') ??
        DateTime.now();
    return AppUserProfile(
      uid: prefs.getString('local_user_uid') ?? 'local-user',
      name: prefs.getString('local_user_name') ?? 'Pocket Sense User',
      email: prefs.getString('local_user_email') ?? '',
      phoneNumber: prefs.getString('profile_phone') ?? '',
      photoUrl: prefs.getString('profile_photo_url'),
      createdAt: createdAt,
    );
  }

  Future<void> updateProfilePhoto(String photoUrl) async {
    final user = _auth?.currentUser;
    await user?.updatePhotoURL(photoUrl);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_photo_url', photoUrl);
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phoneNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final trimmedPhone = phoneNumber.trim();
    final user = _auth?.currentUser;

    if (user != null) {
      if (trimmedName.isNotEmpty) {
        await user.updateDisplayName(trimmedName);
      }
      if (trimmedEmail.isNotEmpty && trimmedEmail != user.email) {
        await user.verifyBeforeUpdateEmail(trimmedEmail);
      }
      await prefs.setString('profile_name', trimmedName);
      await prefs.setString('profile_email', trimmedEmail);
      await prefs.setString('profile_phone', trimmedPhone);
      return;
    }

    await prefs.setString('local_user_name', trimmedName);
    await prefs.setString('local_user_email', trimmedEmail);
    await prefs.setString('profile_phone', trimmedPhone);
  }

  Future<void> _saveProfile(User? user, {String? phoneNumber}) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.setString('local_user_uid', 'local-user');
      await prefs.setString(
        'local_user_created_at',
        DateTime.now().toIso8601String(),
      );
      return;
    }
    await prefs.setString('profile_name', user.displayName ?? '');
    await prefs.setString('profile_email', user.email ?? '');
    if (phoneNumber != null) {
      await prefs.setString('profile_phone', phoneNumber.trim());
    }
    await prefs.setString(
      'profile_created_at',
      prefs.getString('profile_created_at') ??
          user.metadata.creationTime?.toIso8601String() ??
          DateTime.now().toIso8601String(),
    );
    if (user.photoURL != null) {
      await prefs.setString('profile_photo_url', user.photoURL!);
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
