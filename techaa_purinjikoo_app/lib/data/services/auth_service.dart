import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/app_logger.dart';
import '../datasources/remote/api_client.dart';

class UserSession {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isGuest;

  const UserSession({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.isGuest = false,
  });
}

abstract class AuthProvider {
  Future<UserSession> loginWithEmail(String email, String password);
  Future<UserSession> signUpWithEmail(String email, String password, String name);
  Future<UserSession> loginWithGoogle();
  Future<UserSession> loginAsGuest();
  Future<void> sendPasswordReset(String email);
  Future<bool> sendEmailOtp(String email, {String purpose = 'verification'});
  Future<bool> verifyEmailOtp(String email, String otp, {String purpose = 'verification'});
  Future<bool> updateUserPassword(String newPassword);
  Future<void> logout();
  UserSession? getCurrentSession();
}

class FirebaseAuthProvider implements AuthProvider {
  fb.FirebaseAuth? get _firebaseAuth {
    try {
      return fb.FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserSession> loginWithEmail(String email, String password) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      return UserSession(id: 'local_user', email: email, displayName: email.split('@').first);
    }
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      return UserSession(
        id: user.uid,
        email: user.email ?? email,
        displayName: user.displayName ?? email.split('@').first,
        photoUrl: user.photoURL,
      );
    } catch (e) {
      AppLogger.e('Firebase sign-in error', e);
      rethrow;
    }
  }

  @override
  Future<UserSession> signUpWithEmail(String email, String password, String name) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      return UserSession(id: 'local_user', email: email, displayName: name);
    }
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(name);
      return UserSession(
        id: user.uid,
        email: user.email ?? email,
        displayName: name,
        photoUrl: user.photoURL,
      );
    } catch (e) {
      AppLogger.e('Firebase sign-up error', e);
      rethrow;
    }
  }

  @override
  Future<UserSession> loginWithGoogle() async {
    final auth = _firebaseAuth;
    if (auth == null) {
      return const UserSession(
        id: 'google_user',
        email: 'learner@gmail.com',
        displayName: 'Google Learner',
      );
    }
    try {
      // Native In-App Google Account Picker (Android/iOS)
      final googleSignIn = GoogleSignIn(
        serverClientId: '414743824161-fiplqppiho7kbsdn1jujle4kspt61c1u.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Sign-in cancelled by user');
      }

      final googleAuth = await googleUser.authentication;
      final fb.OAuthCredential credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await auth.signInWithCredential(credential);
      final user = userCredential.user!;
      return UserSession(
        id: user.uid,
        email: user.email ?? googleUser.email,
        displayName: user.displayName ?? googleUser.displayName ?? 'Google Learner',
        photoUrl: user.photoURL ?? googleUser.photoUrl,
      );
    } catch (e) {
      AppLogger.e('Google native sign-in error: $e');
      rethrow;
    }
  }

  @override
  Future<UserSession> loginAsGuest() async {
    final auth = _firebaseAuth;
    if (auth == null) {
      return const UserSession(
        id: 'guest_local',
        email: 'guest@techaapurinjikoo.dev',
        displayName: 'Guest Learner',
        isGuest: true,
      );
    }
    try {
      final credential = await auth.signInAnonymously();
      final user = credential.user!;
      return UserSession(
        id: user.uid,
        email: 'guest@techaapurinjikoo.dev',
        displayName: 'Guest Learner',
        isGuest: true,
      );
    } catch (e) {
      AppLogger.e('Firebase guest sign-in error', e);
      return const UserSession(
        id: 'guest_fallback',
        email: 'guest@techaapurinjikoo.dev',
        displayName: 'Guest Learner',
        isGuest: true,
      );
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    final auth = _firebaseAuth;
    if (auth != null && email.isNotEmpty) {
      await auth.sendPasswordResetEmail(email: email.trim());
    }
  }

  @override
  Future<bool> sendEmailOtp(String email, {String purpose = 'verification'}) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) return false;

    // 1. Dispatch real 6-digit OTP using Supabase Auth
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: cleanEmail,
        shouldCreateUser: true,
      );
      return true;
    } on AuthException catch (e) {
      AppLogger.e('Supabase OTP send auth error', e);
      final msg = e.message.toLowerCase();
      if (e.statusCode == '429' || msg.contains('security') || msg.contains('seconds') || msg.contains('rate limit') || msg.contains('frequent')) {
        throw Exception('Frequent OTP request detected. Please wait 60 seconds before requesting another code.');
      }
    } catch (e) {
      AppLogger.e('Supabase OTP send notice', e);
    }

    // 2. Fallback to Go Backend API
    try {
      final res = await ApiClient().post('/api/v1/auth/otp/send', body: {
        'email': cleanEmail,
        'purpose': purpose,
      });
      if (res != null) {
        if (res['success'] == true) return true;
        final errMsg = res['error']?.toString() ?? '';
        if (errMsg.toLowerCase().contains('wait') || errMsg.toLowerCase().contains('rate') || errMsg.toLowerCase().contains('frequent')) {
          throw Exception('Frequent OTP request detected. Please wait 60 seconds before requesting another code.');
        }
      }
      return false;
    } catch (e) {
      if (e.toString().contains('Frequent OTP request')) rethrow;
      AppLogger.e('Failed to send OTP via backend', e);
      return false;
    }
  }

  @override
  Future<bool> verifyEmailOtp(String email, String otp, {String purpose = 'verification'}) async {
    final cleanEmail = email.trim();
    final cleanOtp = otp.trim();
    if (cleanEmail.isEmpty || cleanOtp.isEmpty) return false;

    // 1. Verify 6-digit OTP using Supabase Auth
    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        email: cleanEmail,
        token: cleanOtp,
        type: OtpType.magiclink,
      );
      if (response.session != null || response.user != null) {
        return true;
      }
    } catch (e) {
      AppLogger.e('Supabase OTP verify notice', e);
    }

    // 2. Fallback to Go Backend API
    try {
      final res = await ApiClient().post('/api/v1/auth/otp/verify', body: {
        'email': cleanEmail,
        'code': cleanOtp,
        'purpose': purpose,
      });
      return res != null && res['verified'] == true;
    } catch (e) {
      AppLogger.e('Failed to verify OTP via backend', e);
      return false;
    }
  }

  @override
  Future<bool> updateUserPassword(String newPassword) async {
    final password = newPassword.trim();
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    bool updated = false;

    // 1. Update password in Supabase Auth
    try {
      final response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );
      if (response.user != null) {
        updated = true;
      }
    } on AuthException catch (e) {
      AppLogger.e('Supabase update password auth error', e);
      final msg = e.message.toLowerCase();
      if (msg.contains('different') || msg.contains('same') || e.code == 'same_password') {
        throw Exception('New password must be different from your previous password.');
      }
      throw Exception(e.message);
    } catch (e) {
      AppLogger.d('Supabase update password notice: $e');
    }

    // 2. Update password in Firebase Auth
    try {
      final auth = _firebaseAuth;
      if (auth?.currentUser != null) {
        await auth!.currentUser!.updatePassword(password);
        updated = true;
      }
    } on fb.FirebaseAuthException catch (e) {
      AppLogger.e('Firebase update password auth error', e);
      if (e.code != 'requires-recent-login') {
        throw Exception(e.message ?? 'Failed to update password.');
      }
    } catch (e) {
      AppLogger.d('Firebase update password notice: $e');
    }

    return updated;
  }

  @override
  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    try {
      await _firebaseAuth?.signOut();
    } catch (_) {}
  }

  @override
  UserSession? getCurrentSession() {
    final auth = _firebaseAuth;
    if (auth == null) return null;
    final user = auth.currentUser;
    if (user == null) return null;
    return UserSession(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'Tech Scholar',
      photoUrl: user.photoURL,
      isGuest: user.isAnonymous,
    );
  }
}
