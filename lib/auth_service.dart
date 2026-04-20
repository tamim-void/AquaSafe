import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _profileKey = 'aquasafe_user_profile';

  // ── Password Validation ───────────────────────────────────────────────────
  static String? validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Must contain at least one uppercase letter (A–Z)';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Must contain at least one lowercase letter (a–z)';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Must contain at least one number (0–9)';
    }
    return null;
  }

  // ── Register ──────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final pwError = validatePassword(password);
    if (pwError != null) return {'success': false, 'error': pwError};

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(name.trim());

      // Try sending verification email — but don't fail registration if it errors
      try {
        await cred.user?.sendEmailVerification();
      } catch (_) {
        // Verification email failed but account was created — continue
      }

      await _saveProfile(name.trim(), email.trim());
      return {'success': true};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _mapAuthError(e)};
    } catch (e) {
      return {
        'success': false,
        'error': 'Registration failed: ${e.toString().replaceAll('Exception: ', '')}',
      };
    }
  }

  // ── Resend Verification Email ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'No user found. Please register again.'};
      }
      await user.sendEmailVerification();
      return {'success': true};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _mapAuthError(e)};
    } catch (e) {
      return {'success': false, 'error': 'Failed to send verification email.'};
    }
  }

  // ── Check Email Verified ──────────────────────────────────────────────────
  static Future<bool> isEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (_) {
      return false;
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (cred.user != null && !cred.user!.emailVerified) {
        return {
          'success': false,
          'needsVerification': true,
          'error':
              'Email not verified yet. Check your inbox and click the verification link.',
        };
      }
      final profile = await _loadOrCreateProfile(cred.user!);
      return {'success': true, 'user': profile};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _mapAuthError(e)};
    } catch (e) {
      return {
        'success': false,
        'error': 'Login failed: ${e.toString().replaceAll('Exception: ', '')}',
      };
    }
  }

  // ── Forgot Password ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> sendPasswordResetEmail(
      String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return {'success': true};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _mapAuthError(e)};
    } catch (e) {
      return {'success': false, 'error': 'Something went wrong. Check your connection.'};
    }
  }

  // ── Get Current User ──────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null || !user.emailVerified) return null;
      return _loadOrCreateProfile(user);
    } catch (_) {
      return null;
    }
  }

  // ── Update User ───────────────────────────────────────────────────────────
  static Future<void> updateCurrentUser(Map<String, dynamic> updated) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(updated));
    final user = _auth.currentUser;
    if (user != null && updated['name'] != user.displayName) {
      await user.updateDisplayName(updated['name'] as String?);
    }
  }

  // ── Increment Test Count ──────────────────────────────────────────────────
  static Future<void> incrementTestCount() async {
    final profile = await getCurrentUser();
    if (profile != null) {
      profile['testCount'] = (profile['testCount'] as int? ?? 0) + 1;
      await updateCurrentUser(profile);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  // ── Is Logged In ──────────────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    try {
      final user = _auth.currentUser;
      return user != null && user.emailVerified;
    } catch (_) {
      return false;
    }
  }

  // ── Private Helpers ───────────────────────────────────────────────────────
  static Future<void> _saveProfile(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final profile = {
      'name': name,
      'email': email,
      'joinedDate': DateTime.now().toIso8601String(),
      'testCount': 0,
    };
    await prefs.setString(_profileKey, jsonEncode(profile));
  }

  static Future<Map<String, dynamic>> _loadOrCreateProfile(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw != null) {
      try {
        final p = jsonDecode(raw) as Map<String, dynamic>;
        if (p['email'] == user.email) return p;
      } catch (_) {}
    }
    final profile = {
      'name': user.displayName ?? user.email?.split('@').first ?? 'User',
      'email': user.email ?? '',
      'joinedDate': user.metadata.creationTime?.toIso8601String() ??
          DateTime.now().toIso8601String(),
      'testCount': 0,
    };
    await prefs.setString(_profileKey, jsonEncode(profile));
    return profile;
  }

  // ── Map Firebase error codes to friendly messages ─────────────────────────
  static String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try signing in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Contact support.';
      default:
        // Always show something — never a blank error
        return e.message?.isNotEmpty == true
            ? e.message!
            : 'Authentication failed (${e.code}). Please try again.';
    }
  }
}
