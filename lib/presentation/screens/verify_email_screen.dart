import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabi/config/theme.dart';
import 'package:hisabi/presentation/providers/auth_provider.dart';
import 'package:hisabi/presentation/providers/expense_provider.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _checking = false;
  bool _resending = false;
  String? _message;
  bool _isError = false;

  Future<void> _checkVerification() async {
    setState(() { _checking = true; _message = null; });
    try {
      await FirebaseAuth.instance.currentUser!.reload();
      if (!mounted) return;
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        final onboardingDone = ref.read(onboardingCompletedProvider);
        context.go(onboardingDone ? '/' : '/onboarding');
      } else {
        setState(() { _message = 'Email not verified yet. Check your inbox.'; _isError = true; });
      }
    } catch (_) {
      if (mounted) setState(() { _message = 'Failed to check status. Try again.'; _isError = true; });
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resendEmail() async {
    setState(() { _resending = true; _message = null; });
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      if (mounted) setState(() { _message = 'Verification email resent!'; _isError = false; });
    } catch (_) {
      if (mounted) setState(() { _message = 'Failed to resend. Try again later.'; _isError = true; });
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: kPrimary.withValues(alpha: 0.2), width: 2),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.mark_email_unread_outlined, color: kPrimary, size: 40),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Verify your email',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a verification link to',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: colors.textSec),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Click the link in your email, then come back and tap the button below.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: colors.textSec, height: 1.5),
              ),

              if (_message != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: (_isError ? kDanger : kSuccess).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: (_isError ? kDanger : kSuccess).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isError ? Icons.error_outline : Icons.check_circle_outline,
                        color: _isError ? kDanger : kSuccess,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_message!, style: TextStyle(color: _isError ? kDanger : kSuccess, fontSize: 13))),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),

              GestureDetector(
                onTap: _checking ? null : _checkVerification,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: !_checking ? const LinearGradient(colors: [kPrimaryLight, kPrimary]) : null,
                    color: _checking ? colors.cardAlt : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: !_checking
                        ? [BoxShadow(color: kPrimary.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8))]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: _checking
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text("I've Verified My Email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _resending ? null : _resendEmail,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: _resending
                      ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2))
                      : Text('Resend Email', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: GestureDetector(
                  onTap: () => ref.read(authRepositoryProvider).signOut(),
                  child: Text(
                    'Use a different account',
                    style: TextStyle(fontSize: 14, color: colors.textSec, decoration: TextDecoration.underline, decorationColor: colors.textSec),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
