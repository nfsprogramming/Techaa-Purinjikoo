import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';
import '../../shared/widgets/interactive_pressable.dart';
import 'otp_verification_sheet.dart';
import 'reset_password_sheet.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _agreeToTerms = false; // Unchecked by default per user request
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
      return;
    }

    if (_isSignUp && name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your full name.');
      return;
    }

    if (_isSignUp && !_agreeToTerms) {
      setState(() => _errorMessage = 'Please accept the Terms & Privacy Policy to register.');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        await ref.read(authRepositoryProvider.notifier).signUp(email, password, name);
      } else {
        await ref.read(authRepositoryProvider.notifier).login(email, password);
      }
      if (mounted) context.go('/home');
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      String readableError;
      if (errStr.contains('user-not-found')) {
        readableError = 'No account exists for this email. Tap "Create Account" above to register!';
      } else if (errStr.contains('wrong-password') || errStr.contains('invalid-credential')) {
        readableError = 'Invalid email or password. Please try again.';
      } else if (errStr.contains('invalid-email')) {
        readableError = 'Invalid email address format.';
      } else if (errStr.contains('email-already-in-use')) {
        readableError = 'An account with this email already exists. Switch to Sign In!';
      } else if (errStr.contains('weak-password')) {
        readableError = 'Password is too weak. Must be at least 6 characters.';
      } else if (errStr.contains('network-request-failed')) {
        readableError = 'Network error. Please check your connection.';
      } else if (errStr.contains('too-many-requests')) {
        readableError = 'Too many failed attempts. Please try again later.';
      } else {
        readableError = 'Sign-in failed. Please check your email/password or create an account.';
      }

      setState(() {
        _errorMessage = readableError;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Enter your email address above, then tap "Forgot Password?".');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // 1. Dispatch 6-digit OTP email via Supabase Auth
      await ref.read(authRepositoryProvider.notifier).sendEmailOtp(email, purpose: 'reset_password');

      if (mounted) {
        // 2. Show smooth in-app OTP verification sheet
        await OtpVerificationSheet.show(
          context,
          email: email,
          purpose: 'reset_password',
          onVerified: () {
            // Open the Set New Password Sheet immediately
            ResetPasswordSheet.show(
              context,
              email: email,
              onPasswordUpdated: () {
                _passwordController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF065F46),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Password updated successfully! Please sign in with your new password.',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() => _errorMessage = msg.isNotEmpty ? msg : 'Could not dispatch verification code. Please verify the email.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider.notifier).loginWithGoogle();
      if (mounted) context.go('/home');
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (!msg.contains('cancel')) {
        setState(() {
          _errorMessage = 'Google sign-in failed. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider.notifier).loginAsGuest();
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() {
        _errorMessage = 'Guest sign-in failed. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryAccent = Color(0xFF6366F1); // Indigo
    const secondaryAccent = Color(0xFFEF4444); // Brand Red

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Stack(
        children: [
          // 1. Ambient Background Glow Orbs
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryAccent.withValues(alpha: 0.18),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -50,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryAccent.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo Card with Sleek Glassmorphism
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 18,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.terminal_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Brand Titles
                      const Text(
                        'Techaa Purinjikoo',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isSignUp
                            ? 'Create an account to track your progress & XP'
                            : 'Welcome back! Sign in to continue learning',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Modern Glassmorphic Form Card
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E1626).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeInOutCubic,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Sleek Liquid Morphing Tab Switcher
                              _LiquidAuthTabSwitcher(
                                isSignUp: _isSignUp,
                                onChanged: (isSignUp) {
                                  setState(() {
                                    _isSignUp = isSignUp;
                                    _errorMessage = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),

                            // Error Alert
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.redAccent.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline_rounded,
                                      color: Colors.redAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: Color(0xFFFCA5A5),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],

                            // Name Field (Sign Up Only)
                            if (_isSignUp) ...[
                              _buildFieldLabel('Full Name'),
                              const SizedBox(height: 4),
                              _buildTextField(
                                controller: _nameController,
                                hintText: 'Enter your name',
                                icon: Icons.person_outline_rounded,
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 10),
                            ],

                            // Email Field
                            _buildFieldLabel('Email Address'),
                            const SizedBox(height: 4),
                            _buildTextField(
                              controller: _emailController,
                              hintText: 'name@example.com',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 10),

                            // Password Field
                            _buildFieldLabel('Password'),
                            const SizedBox(height: 4),
                            _buildTextField(
                              controller: _passwordController,
                              hintText: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF64748B),
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),

                            // Forgot Password Link
                            if (!_isSignUp) ...[
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: _handleForgotPassword,
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Color(0xFF818CF8),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            // Terms & Privacy Checkbox (Always visible)
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: _agreeToTerms,
                                    onChanged: (val) => setState(() => _agreeToTerms = val ?? false),
                                    activeColor: const Color(0xFF6366F1),
                                    checkColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.35),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      const Text(
                                        'I agree to the ',
                                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                      ),
                                      GestureDetector(
                                        onTap: () => _showTermsModal(context, isPrivacyPolicy: false),
                                        child: const Text(
                                          'Terms of Service',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF818CF8),
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        ' & ',
                                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                      ),
                                      GestureDetector(
                                        onTap: () => _showTermsModal(context, isPrivacyPolicy: true),
                                        child: const Text(
                                          'Privacy Policy',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF818CF8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Submit Button
                            InteractivePressable(
                              onTap: _isLoading ? null : _handleSubmit,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFEF4444), Color(0xFF6366F1)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          _isSignUp ? 'Create Account' : 'Sign In to Account',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13.5,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ),
                      const SizedBox(height: 12),

                      // Social / Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'OR CONTINUE WITH',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.35),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Sign in with Google Button
                      InteractivePressable(
                        onTap: _isLoading ? null : _handleGoogleLogin,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/google_logo.png',
                                    width: 13,
                                    height: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Continue as Guest Pill Button
                      InteractivePressable(
                        onTap: _isLoading ? null : _handleGuestLogin,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.admin_panel_settings_rounded,
                                color: Color(0xFF818CF8),
                                size: 16,
                              ),
                              SizedBox(width: 7),
                              Text(
                                'Login as Guest',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Clean Brand Footer
                      Text(
                        '© 2026 Techaa Purinjikoo • By NFS Programming',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF64748B).withValues(alpha: 0.8),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsModal(BuildContext context, {required bool isPrivacyPolicy}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.82,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Drag indicator bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isPrivacyPolicy
                              ? Icons.shield_outlined
                              : Icons.description_outlined,
                          color: const Color(0xFF818CF8),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isPrivacyPolicy ? 'Privacy Policy' : 'Terms of Service',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              // Scrollable Legal Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  child: isPrivacyPolicy
                      ? _buildPrivacyPolicyContent()
                      : _buildTermsOfServiceContent(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTermsOfServiceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Last Updated: August 2026',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 14),
        _buildSection(
          '1. Welcome to Techaa Purinjikoo',
          'Techaa Purinjikoo ("we", "our", or "us") is an interactive developer learning and mastery platform built by NFS Programming. By accessing or using our application, you agree to comply with and be bound by these Terms of Service.',
        ),
        _buildSection(
          '2. Learning & Gamification Platform',
          'Our service provides conceptual computer science lessons, real-world analogies in Tanglish & English, interactive flashcards, daily quizzes, and multiplayer topic battle arenas. You agree to use these services solely for personal educational self-improvement.',
        ),
        _buildSection(
          '3. User Accounts & Security',
          'You are responsible for maintaining the confidentiality of your login credentials and for all activities under your account. We reserve the right to suspend or terminate accounts that violate community safety or use automated bots.',
        ),
        _buildSection(
          '4. Fair Play in Quizzes & Battle Mode',
          'Battle Arena and Quiz ratings, XP, and streak scores must be earned genuinely. Any attempt to manipulate scores, exploit vulnerabilities, or use automated solvers is strictly prohibited and subject to XP resets.',
        ),
        _buildSection(
          '5. Content & Intellectual Property',
          'All flashcards, questions, analogies, user interface components, and custom illustrations belong to NFS Programming and Techaa Purinjikoo. You may not reproduce, redistribute, or reverse engineer any part of the app without explicit written consent.',
        ),
        _buildSection(
          '6. Modifications & Contact',
          'We may update these terms periodically to reflect new features. Continued use of the app constitutes acceptance of any revised terms. For queries, contact us at support@techaapurinjikoo.dev.',
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPrivacyPolicyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Last Updated: August 2026',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 14),
        _buildSection(
          '1. Information We Collect',
          '• Account Info: Email address, display name, and avatar image when you register via Email or Google Sign-In.\n• Learning Progress: Quiz scores, daily streaks, XP points, flashcard mastery levels (Again, Hard, Good, Easy), and topic battle statistics.\n• Guest Sessions: Minimal local identifiers to allow instant access without permanent account linking.',
        ),
        _buildSection(
          '2. How We Use Your Information',
          'We use the collected information exclusively to:\n• Synchronize your learning progress across your devices.\n• Personalize flashcard repetitions based on your spaced-repetition ratings.\n• Maintain competitive global and topic leaderboards.\n• Provide secure, frictionless authentication.',
        ),
        _buildSection(
          '3. Data Protection & Firebase Infrastructure',
          'We use Google Firebase (Firebase Authentication and Cloud Firestore) to protect your account data. All transmissions are encrypted in transit via SSL/TLS and stored with industry-standard security.',
        ),
        _buildSection(
          '4. No Data Selling',
          'We do not sell, rent, or trade your personal information to third parties, advertising networks, or data brokers. Your learning journey is strictly yours.',
        ),
        _buildSection(
          '5. Your Rights & Account Deletion',
          'You can request complete deletion of your account and all associated XP and streak records at any time from within the Profile settings or by emailing privacy@techaapurinjikoo.dev.',
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFFF1F5F9),
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFFCBD5E1),
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080D1A),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 12.5,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF64748B),
            size: 18,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}

class _LiquidAuthTabSwitcher extends StatefulWidget {
  final bool isSignUp;
  final ValueChanged<bool> onChanged;

  const _LiquidAuthTabSwitcher({
    required this.isSignUp,
    required this.onChanged,
  });

  @override
  State<_LiquidAuthTabSwitcher> createState() => _LiquidAuthTabSwitcherState();
}

class _LiquidAuthTabSwitcherState extends State<_LiquidAuthTabSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _prevPos = 0.0;
  double _targetPos = 0.0;

  static const Curve liquidSpring = Cubic(0.34, 1.45, 0.64, 1.0);

  @override
  void initState() {
    super.initState();
    _prevPos = widget.isSignUp ? 1.0 : 0.0;
    _targetPos = _prevPos;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(_LiquidAuthTabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSignUp != widget.isSignUp) {
      _prevPos = _targetPos;
      _targetPos = widget.isSignUp ? 1.0 : 0.0;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF080D1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final tabWidth = totalWidth / 2;

          return Stack(
            children: [
              // Liquid Morphing Pill
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = _controller.isAnimating
                      ? liquidSpring.transform(_controller.value)
                      : 1.0;

                  final currentPos = _prevPos + (_targetPos - _prevPos) * t;
                  final distance = (_targetPos - _prevPos).abs();

                  // Dynamic liquid stretch
                  final stretch = distance * math.sin(t * math.pi) * 16.0;
                  final isMovingRight = _targetPos > _prevPos;

                  final desiredLeft = isMovingRight
                      ? (currentPos * tabWidth)
                      : (currentPos * tabWidth) - stretch;

                  final desiredWidth = tabWidth + stretch;
                  final desiredRight = desiredLeft + desiredWidth;

                  final actualLeft = desiredLeft.clamp(0.0, totalWidth);
                  final actualRight = desiredRight.clamp(0.0, totalWidth);
                  final actualWidth = (actualRight - actualLeft).clamp(0.0, totalWidth);

                  return Positioned(
                    left: actualLeft,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: actualWidth,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.14),
                            blurRadius: 10,
                            spreadRadius: -1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Clickable Labels
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => widget.onChanged(false),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: !widget.isSignUp ? FontWeight.w700 : FontWeight.w500,
                            color: !widget.isSignUp ? Colors.white : const Color(0xFF64748B),
                            letterSpacing: 0.2,
                          ),
                          child: const Text('Sign In'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => widget.onChanged(true),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: widget.isSignUp ? FontWeight.w700 : FontWeight.w500,
                            color: widget.isSignUp ? Colors.white : const Color(0xFF64748B),
                            letterSpacing: 0.2,
                          ),
                          child: const Text('Create Account'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
