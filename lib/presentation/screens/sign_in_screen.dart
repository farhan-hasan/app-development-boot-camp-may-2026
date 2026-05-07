import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabi/config/theme.dart';
import 'package:hisabi/presentation/providers/auth_provider.dart';
import 'package:hisabi/presentation/widgets/next_field_bar.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _obscure = ValueNotifier<bool>(true);
  final _loading = ValueNotifier<bool>(false);
  final _googleLoading = ValueNotifier<bool>(false);
  final _error = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _obscure.dispose();
    _loading.dispose();
    _googleLoading.dispose();
    _error.dispose();
    super.dispose();
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      case 'network-request-failed':
        return 'No internet connection';
      default:
        return 'Something went wrong. Please try again';
    }
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      _error.value = 'Please fill in all fields';
      return;
    }
    _loading.value = true;
    _error.value = null;
    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmailPassword(email, password);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _error.value = _mapError(e);
        _loading.value = false;
      }
    } catch (_) {
      if (mounted) {
        _error.value = 'Something went wrong';
        _loading.value = false;
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    _error.value = null;
    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithGoogle(
            onAccountSelected: () {
              if (mounted) _googleLoading.value = true;
            },
          );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _error.value = _mapError(e);
        _googleLoading.value = false;
      }
    } catch (e) {
      debugPrint("===================>$e");
      if (mounted) {
        _error.value = e.toString().contains('cancelled')
            ? null
            : 'Google sign-in failed';
        _googleLoading.value = false;
      }
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _error.value = 'Enter your email address first';
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to $email'),
            backgroundColor: kSuccess,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
      }
    } catch (_) {
      if (mounted) _error.value = 'Failed to send reset email';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ListenableBuilder(
      listenable: Listenable.merge([
        _obscure,
        _loading,
        _googleLoading,
        _error,
      ]),
      builder: (_, __) => Scaffold(
        backgroundColor: colors.bg,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          width: 88,
                          height: 88,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(fontSize: 15, color: colors.textSec),
                      ),
                      const SizedBox(height: 36),
                      _AuthField(
                        label: 'Email',
                        icon: Icons.email_outlined,
                        controller: _emailCtrl,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                        colors: colors,
                      ),
                      const SizedBox(height: 12),
                      _AuthField(
                        label: 'Password',
                        icon: Icons.lock_outline,
                        controller: _passwordCtrl,
                        focusNode: _passwordFocus,
                        obscureText: _obscure.value,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _loading.value ? null : _signIn(),
                        colors: colors,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: colors.textSec,
                            size: 20,
                          ),
                          onPressed: () => _obscure.value = !_obscure.value,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _loading.value ? null : _forgotPassword,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 13,
                              color: kPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (_error.value != null) ...[
                        const SizedBox(height: 8),
                        _ErrorBanner(message: _error.value!),
                      ],
                      const SizedBox(height: 20),
                      _PrimaryButton(
                        label: 'Sign In',
                        loading: _loading.value,
                        onTap: _loading.value ? null : _signIn,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: colors.border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'or',
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.textSec,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: colors.border)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _GoogleButton(
                        loading: _googleLoading.value,
                        onTap: (_loading.value || _googleLoading.value)
                            ? null
                            : _signInWithGoogle,
                        colors: colors,
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textSec,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/sign-up'),
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                fontSize: 14,
                                color: kPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ListenableBuilder(
                listenable: Listenable.merge([_emailFocus, _passwordFocus]),
                builder: (ctx, __) {
                  if (_emailFocus.hasFocus) {
                    return NextFieldBar(
                      colors: colors,
                      onNext: () => _passwordFocus.requestFocus(),
                    );
                  }
                  if (_passwordFocus.hasFocus) {
                    return NextFieldBar(
                      colors: colors,
                      onNext: () => FocusScope.of(ctx).unfocus(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sign Up Screen
// ---------------------------------------------------------------------------

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  final _obscurePassword = ValueNotifier<bool>(true);
  final _obscureConfirm = ValueNotifier<bool>(true);
  final _loading = ValueNotifier<bool>(false);
  final _googleLoading = ValueNotifier<bool>(false);
  final _error = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _obscurePassword.dispose();
    _obscureConfirm.dispose();
    _loading.dispose();
    _googleLoading.dispose();
    _error.dispose();
    super.dispose();
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'invalid-email':
        return 'Invalid email address';
      case 'network-request-failed':
        return 'No internet connection';
      default:
        return 'Something went wrong. Please try again';
    }
  }

  Future<void> _signUp() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _error.value = 'Please fill in all fields';
      return;
    }
    if (password != confirm) {
      _error.value = 'Passwords do not match';
      return;
    }
    if (password.length < 6) {
      _error.value = 'Password must be at least 6 characters';
      return;
    }

    _loading.value = true;
    _error.value = null;
    try {
      await ref
          .read(authRepositoryProvider)
          .signUpWithEmailPassword(email, password, name);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _error.value = _mapError(e);
        _loading.value = false;
      }
    } catch (_) {
      if (mounted) {
        _error.value = 'Something went wrong';
        _loading.value = false;
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    _error.value = null;
    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithGoogle(
            onAccountSelected: () {
              if (mounted) _googleLoading.value = true;
            },
          );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _error.value = e.message;
        _googleLoading.value = false;
      }
    } catch (e) {
      if (mounted) {
        _error.value = e.toString().contains('cancelled')
            ? null
            : 'Google sign-in failed';
        _googleLoading.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ListenableBuilder(
      listenable: Listenable.merge([
        _obscurePassword,
        _obscureConfirm,
        _loading,
        _googleLoading,
        _error,
      ]),
      builder: (_, __) => Scaffold(
        backgroundColor: colors.bg,
        appBar: AppBar(
          backgroundColor: colors.bg,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.cardAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: colors.textPrimary,
              ),
            ),
          ),
          title: Text(
            'Create Account',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Join Hisabi',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Start tracking your expenses today',
                        style: TextStyle(fontSize: 15, color: colors.textSec),
                      ),
                      const SizedBox(height: 32),
                      _AuthField(
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        controller: _nameCtrl,
                        focusNode: _nameFocus,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _emailFocus.requestFocus(),
                        colors: colors,
                      ),
                      const SizedBox(height: 12),
                      _AuthField(
                        label: 'Email',
                        icon: Icons.email_outlined,
                        controller: _emailCtrl,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                        colors: colors,
                      ),
                      const SizedBox(height: 12),
                      _AuthField(
                        label: 'Password',
                        icon: Icons.lock_outline,
                        controller: _passwordCtrl,
                        focusNode: _passwordFocus,
                        obscureText: _obscurePassword.value,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _confirmFocus.requestFocus(),
                        colors: colors,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: colors.textSec,
                            size: 20,
                          ),
                          onPressed: () =>
                              _obscurePassword.value = !_obscurePassword.value,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AuthField(
                        label: 'Confirm Password',
                        icon: Icons.lock_outline,
                        controller: _confirmCtrl,
                        focusNode: _confirmFocus,
                        obscureText: _obscureConfirm.value,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _loading.value ? null : _signUp(),
                        colors: colors,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: colors.textSec,
                            size: 20,
                          ),
                          onPressed: () =>
                              _obscureConfirm.value = !_obscureConfirm.value,
                        ),
                      ),
                      if (_error.value != null) ...[
                        const SizedBox(height: 16),
                        _ErrorBanner(message: _error.value!),
                      ],
                      const SizedBox(height: 24),
                      _PrimaryButton(
                        label: 'Create Account',
                        loading: _loading.value,
                        onTap: _loading.value ? null : _signUp,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: colors.border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'or',
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.textSec,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: colors.border)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _GoogleButton(
                        loading: _googleLoading.value,
                        onTap: (_loading.value || _googleLoading.value)
                            ? null
                            : _signInWithGoogle,
                        colors: colors,
                      ),
                      const SizedBox(height: 36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textSec,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: 14,
                                color: kPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ListenableBuilder(
                listenable: Listenable.merge([
                  _nameFocus,
                  _emailFocus,
                  _passwordFocus,
                  _confirmFocus,
                ]),
                builder: (ctx, __) {
                  if (_nameFocus.hasFocus) {
                    return NextFieldBar(
                      colors: colors,
                      onNext: () => _emailFocus.requestFocus(),
                    );
                  }
                  if (_emailFocus.hasFocus) {
                    return NextFieldBar(
                      colors: colors,
                      onNext: () => _passwordFocus.requestFocus(),
                    );
                  }
                  if (_passwordFocus.hasFocus) {
                    return NextFieldBar(
                      colors: colors,
                      onNext: () => _confirmFocus.requestFocus(),
                    );
                  }
                  if (_confirmFocus.hasFocus) {
                    return NextFieldBar(
                      colors: colors,
                      onNext: () => FocusScope.of(ctx).unfocus(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.colors,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.obscureText = false,
    this.suffixIcon,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final AppColors colors;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      obscureText: obscureText,
      style: TextStyle(fontSize: 15, color: colors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.textSec, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: kPrimary, fontSize: 13),
        prefixIcon: Icon(icon, color: colors.textSec, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colors.card,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: kPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: !loading
              ? const LinearGradient(colors: [kPrimaryLight, kPrimary])
              : null,
          color: loading ? context.appColors.cardAlt : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: !loading
              ? [
                  BoxShadow(
                    color: kPrimary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    required this.loading,
    required this.onTap,
    required this.colors,
  });

  final bool loading;
  final VoidCallback? onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: kPrimary,
                ),
              )
            else
              SvgPicture.asset('assets/google_logo.svg', width: 22, height: 22),
            const SizedBox(width: 12),
            Text(
              loading ? 'Signing in...' : 'Continue with Google',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kDanger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kDanger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: kDanger, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: kDanger, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
