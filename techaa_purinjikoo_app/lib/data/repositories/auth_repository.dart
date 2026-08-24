import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthProvider>((ref) {
  return FirebaseAuthProvider();
});

class AuthRepository extends Notifier<UserSession?> {
  late final AuthProvider _authService;

  @override
  UserSession? build() {
    _authService = ref.read(authServiceProvider);
    return _authService.getCurrentSession();
  }

  Future<void> login(String email, String password) async {
    final session = await _authService.loginWithEmail(email, password);
    state = session;
  }

  Future<void> signUp(String email, String password, String name) async {
    final session = await _authService.signUpWithEmail(email, password, name);
    state = session;
  }

  Future<void> loginWithGoogle() async {
    final session = await _authService.loginWithGoogle();
    state = session;
  }

  Future<void> loginAsGuest() async {
    final session = await _authService.loginAsGuest();
    state = session;
  }

  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordReset(email);
  }

  Future<bool> sendEmailOtp(String email, {String purpose = 'verification'}) async {
    return await _authService.sendEmailOtp(email, purpose: purpose);
  }

  Future<bool> verifyEmailOtp(String email, String otp, {String purpose = 'verification'}) async {
    return await _authService.verifyEmailOtp(email, otp, purpose: purpose);
  }

  Future<bool> updateUserPassword(String newPassword) async {
    return await _authService.updateUserPassword(newPassword);
  }

  Future<void> logout() async {
    await _authService.logout();
    state = null;
  }
}

final authRepositoryProvider = NotifierProvider<AuthRepository, UserSession?>(AuthRepository.new);
