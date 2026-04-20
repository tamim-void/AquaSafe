import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _resetEmailCtrl = TextEditingController();

  bool _isRegister = false;
  bool _loading    = false;
  bool _obscure    = true;
  String? _error;
  String? _success;

  // Verification waiting state
  bool _waitingVerification = false;
  Timer? _verificationTimer;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _resetEmailCtrl.dispose();
    _fadeCtrl.dispose();
    _verificationTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  // ── Form Validation ─────────────────────────────────────────────────────
  bool _validateForm() {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final name     = _nameCtrl.text.trim();

    setState(() { _error = null; _success = null; });

    if (_isRegister && name.isEmpty) {
      setState(() => _error = 'Please enter your full name.');
      return false;
    }
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return false;
    }
    if (!RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$').hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address.');
      return false;
    }
    if (password.isEmpty) {
      setState(() => _error = 'Please enter your password.');
      return false;
    }
    if (_isRegister) {
      final pwError = AuthService.validatePassword(password);
      if (pwError != null) {
        setState(() => _error = pwError);
        return false;
      }
    }
    return true;
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_validateForm()) return;
    setState(() { _loading = true; _error = null; _success = null; });

    if (_isRegister) {
      final result = await AuthService.register(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      setState(() => _loading = false);

      if (result['success'] == true) {
        // Show verification waiting UI
        setState(() {
          _waitingVerification = true;
          _success = 'Verification email sent! Check your inbox and click the link.';
        });
        _startVerificationPolling();
        _startResendCooldown();
      } else {
        setState(() => _error = result['error'] as String?);
      }
    } else {
      // Login
      final result = await AuthService.login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      setState(() => _loading = false);

      if (result['success'] == true) {
        if (mounted) Navigator.pushReplacementNamed(context, '/main');
      } else if (result['needsVerification'] == true) {
        setState(() {
          _waitingVerification = true;
          _error = result['error'] as String?;
        });
        _startVerificationPolling();
        _startResendCooldown();
      } else {
        setState(() => _error = result['error'] as String?);
      }
    }
  }

  // ── Poll for Email Verification ───────────────────────────────────────────
  void _startVerificationPolling() {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final verified = await AuthService.isEmailVerified();
      if (verified && mounted) {
        _verificationTimer?.cancel();
        Navigator.pushReplacementNamed(context, '/main');
      }
    });
  }

  // ── Resend Cooldown ───────────────────────────────────────────────────────
  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  Future<void> _resendVerification() async {
    if (_resendCooldown > 0) return;
    final result = await AuthService.resendVerificationEmail();
    if (mounted) {
      if (result['success'] == true) {
        _startResendCooldown();
        setState(() => _success = 'Verification email resent! Check your inbox.');
      } else {
        setState(() => _error = result['error'] as String?);
      }
    }
  }

  // ── Forgot Password Dialog ────────────────────────────────────────────────
  void _showForgotPasswordDialog() {
    _resetEmailCtrl.text = _emailCtrl.text.trim();
    showDialog(
      context: context,
      builder: (ctx) {
        String? dialogError;
        String? dialogSuccess;
        bool dialogLoading = false;

        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            backgroundColor: AppTheme.snowSurface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            title: Text(
              'Reset Password',
              style: GoogleFonts.outfit(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your email address. We\'ll send you a link to reset your password.',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _resetEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.outfit(
                      color: AppTheme.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'you@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                if (dialogError != null) ...[
                  const SizedBox(height: 12),
                  Text(dialogError!,
                      style: GoogleFonts.outfit(
                          color: AppTheme.dangerRed, fontSize: 12)),
                ],
                if (dialogSuccess != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.safeGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppTheme.safeGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: AppTheme.safeGreen, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(dialogSuccess!,
                              style: GoogleFonts.outfit(
                                  color: AppTheme.safeGreen, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel',
                    style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: dialogLoading
                    ? null
                    : () async {
                        final email = _resetEmailCtrl.text.trim();
                        if (email.isEmpty) {
                          setDialogState(
                              () => dialogError = 'Enter your email.');
                          return;
                        }
                        setDialogState(() {
                          dialogLoading = true;
                          dialogError = null;
                          dialogSuccess = null;
                        });

                        final result =
                            await AuthService.sendPasswordResetEmail(email);

                        setDialogState(() {
                          dialogLoading = false;
                          if (result['success'] == true) {
                            dialogSuccess =
                                'Reset link sent! Check your email.';
                            dialogError = null;
                          } else {
                            dialogError = result['error'] as String?;
                          }
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.electricBlue,
                ),
                child: dialogLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Send Reset Link',
                        style: GoogleFonts.outfit(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _skipLogin() => Navigator.pushReplacementNamed(context, '/main');

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.06),

                  // ── Logo ──────────────────────────────────────────────
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.frostCard,
                      border: Border.all(
                          color: AppTheme.electricBlue.withOpacity(0.4),
                          width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.electricBlue.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.water_drop,
                        color: AppTheme.electricBlue, size: 40),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'AQUASAFE',
                    style: GoogleFonts.outfit(
                      color: AppTheme.electricBlue,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _waitingVerification
                        ? 'Verify your email'
                        : _isRegister
                            ? 'Create your account'
                            : 'Sign in to continue',
                    style: GoogleFonts.outfit(
                        color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 30),

                  // ── Verification Waiting View ─────────────────────────
                  if (_waitingVerification) ...[
                    _buildVerificationWaiting(),
                  ] else ...[
                    // ── Form Card ───────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.frostCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderDim),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name field (register only)
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: _isRegister
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _fieldLabel('FULL NAME'),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: _nameCtrl,
                                        style: GoogleFonts.outfit(
                                            color: AppTheme.textPrimary,
                                            fontSize: 14),
                                        decoration: const InputDecoration(
                                          hintText: 'Your name',
                                          prefixIcon: Icon(
                                              Icons.person_outline,
                                              size: 20),
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),

                          // Email
                          _fieldLabel('EMAIL'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.outfit(
                                color: AppTheme.textPrimary, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'you@email.com',
                              prefixIcon:
                                  Icon(Icons.email_outlined, size: 20),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Password
                          _fieldLabel('PASSWORD'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            onChanged: (_) {
                              if (_isRegister) setState(() {});
                            },
                            style: GoogleFonts.outfit(
                                color: AppTheme.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline,
                                  size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                          ),

                          // Forgot Password (login only)
                          if (!_isRegister) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPasswordDialog,
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.electricBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          // Password rules (register only)
                          if (_isRegister) ...[
                            const SizedBox(height: 12),
                            _buildPasswordRules(),
                          ],

                          // Error
                          if (_error != null) ...[
                            const SizedBox(height: 14),
                            _buildErrorBanner(_error!),
                          ],

                          const SizedBox(height: 20),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.electricBlue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppTheme.iceWhite),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _isRegister
                                              ? Icons
                                                  .person_add_alt_1_outlined
                                              : Icons.login_outlined,
                                          color: AppTheme.iceWhite,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          _isRegister
                                              ? 'CREATE ACCOUNT'
                                              : 'SIGN IN',
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.iceWhite,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Toggle login/register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isRegister
                              ? 'Already have an account?'
                              : 'Don\'t have an account?',
                          style: GoogleFonts.outfit(
                              color: AppTheme.textMuted, fontSize: 13),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _isRegister = !_isRegister;
                            _error = null;
                            _success = null;
                          }),
                          child: Text(
                            _isRegister ? 'Sign In' : 'Register',
                            style: GoogleFonts.outfit(
                              color: AppTheme.electricBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Skip
                    TextButton(
                      onPressed: _skipLogin,
                      child: Text(
                        'Skip for now',
                        style: GoogleFonts.outfit(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Verification Waiting UI ───────────────────────────────────────────────
  Widget _buildVerificationWaiting() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.frostCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDim),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.electricBlue.withOpacity(0.1),
            ),
            child: const Icon(Icons.mark_email_read_outlined,
                color: AppTheme.electricBlue, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            'Check Your Email',
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.outfit(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.6),
              children: [
                const TextSpan(
                    text: 'We sent a verification link to\n'),
                TextSpan(
                  text: _emailCtrl.text.trim(),
                  style: GoogleFonts.outfit(
                    color: AppTheme.electricBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(
                    text:
                        '\n\nClick the link in the email to verify your account. This page will automatically redirect once verified.'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Checking indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.electricBlue.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Waiting for verification...',
                style: GoogleFonts.outfit(
                    color: AppTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Success message
          if (_success != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.safeGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppTheme.safeGreen.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: AppTheme.safeGreen, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_success!,
                        style: GoogleFonts.outfit(
                            color: AppTheme.safeGreen, fontSize: 12)),
                  ),
                ],
              ),
            ),

          // Error
          if (_error != null) ...[
            _buildErrorBanner(_error!),
            const SizedBox(height: 12),
          ],

          // Resend button
          TextButton.icon(
            onPressed: _resendCooldown == 0 ? _resendVerification : null,
            icon: Icon(Icons.refresh,
                size: 16,
                color: _resendCooldown == 0
                    ? AppTheme.electricBlue
                    : AppTheme.textMuted),
            label: Text(
              _resendCooldown > 0
                  ? 'Resend in ${_resendCooldown}s'
                  : 'Resend verification email',
              style: GoogleFonts.outfit(
                color: _resendCooldown == 0
                    ? AppTheme.electricBlue
                    : AppTheme.textMuted,
                fontSize: 13,
                fontWeight: _resendCooldown == 0
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Back to login
          TextButton(
            onPressed: () {
              _verificationTimer?.cancel();
              _cooldownTimer?.cancel();
              setState(() {
                _waitingVerification = false;
                _isRegister = false;
                _error = null;
                _success = null;
              });
            },
            child: Text(
              'Back to Sign In',
              style: GoogleFonts.outfit(
                color: AppTheme.textMuted,
                fontSize: 13,
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared Widgets ────────────────────────────────────────────────────────
  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.dangerRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.dangerRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: AppTheme.dangerRed, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: GoogleFonts.outfit(
                    color: AppTheme.dangerRed, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRules() {
    final pw = _passwordCtrl.text;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.snowSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password requirements:',
            style: GoogleFonts.outfit(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          _RuleRow(met: pw.length >= 8, label: 'At least 8 characters'),
          _RuleRow(
              met: RegExp(r'[A-Z]').hasMatch(pw),
              label: 'One uppercase letter (A–Z)'),
          _RuleRow(
              met: RegExp(r'[a-z]').hasMatch(pw),
              label: 'One lowercase letter (a–z)'),
          _RuleRow(
              met: RegExp(r'[0-9]').hasMatch(pw),
              label: 'One number (0–9)'),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        color: AppTheme.textSecondary,
        fontSize: 10,
        letterSpacing: 2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final bool met;
  final String label;
  const _RuleRow({required this.met, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: met ? AppTheme.safeGreen : AppTheme.textMuted,
          ),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.outfit(
                color: met ? AppTheme.safeGreen : AppTheme.textMuted,
                fontSize: 11,
              )),
        ],
      ),
    );
  }
}
