import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import 'main_shell.dart';
import 'privacy_policy_screen.dart';
import '../services/firebase_auth_service.dart';

class FirebaseAuthGate extends StatefulWidget {
  const FirebaseAuthGate({required this.service, super.key});

  final FirebaseAuthService service;

  @override
  State<FirebaseAuthGate> createState() => _FirebaseAuthGateState();
}

class _FirebaseAuthGateState extends State<FirebaseAuthGate> {
  bool _continueAsGuest = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: widget.service.authStateChanges,
      initialData: widget.service.currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF7E55)),
            ),
          );
        }
        if (snapshot.data == null) {
          if (_continueAsGuest) return const MainShell();
          return FirebaseAuthScreen(
            service: widget.service,
            onContinueAsGuest: () {
              setState(() => _continueAsGuest = true);
            },
          );
        }
        return MainShell(authService: widget.service);
      },
    );
  }
}

class FirebaseAuthScreen extends StatefulWidget {
  const FirebaseAuthScreen({
    required this.service,
    this.onContinueAsGuest,
    super.key,
  });

  final FirebaseAuthService service;
  final VoidCallback? onContinueAsGuest;

  @override
  State<FirebaseAuthScreen> createState() => _FirebaseAuthScreenState();
}

class _FirebaseAuthScreenState extends State<FirebaseAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isCreatingAccount = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isCreatingAccount) {
        await widget.service.createAccount(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await widget.service.signInWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _errorMessage = _firebaseError(error));
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = _readableError(error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await widget.service.signInWithGoogle();
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _errorMessage = _firebaseError(error));
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = _readableError(error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _firebaseError(FirebaseAuthException error) {
    return switch (error.code) {
      'email-already-in-use' => 'An account already exists for this email.',
      'invalid-email' => 'Enter a valid email address.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' =>
        'The email or password is incorrect.',
      'weak-password' => 'Choose a password with at least 6 characters.',
      'network-request-failed' =>
        'Could not connect. Check your internet connection and try again.',
      _ => 'Authentication failed. Please try again.',
    };
  }

  String _readableError(Object error) {
    if (error is StateError) return error.message;
    return 'Sign-in failed. Check your connection and account settings.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/icons/app_logo_mark.png',
                      width: 64,
                      height: 64,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.grass_rounded,
                        size: 64,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Welcome to PalayPlan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF12342E),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isCreatingAccount
                          ? 'Create an account to get started.'
                          : 'Sign in to continue to your farm dashboard.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF4A5568),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty || !email.contains('@')) {
                          return 'Enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: _isCreatingAccount
                          ? TextInputAction.next
                          : TextInputAction.done,
                      autofillHints: [
                        _isCreatingAccount
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').length < 6) {
                          return 'Use at least 6 characters.';
                        }
                        return null;
                      },
                    ),
                    if (_isCreatingAccount) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match.';
                          }
                          return null;
                        },
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFB3261E),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isCreatingAccount
                                    ? 'Create account'
                                    : 'Sign in',
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: const Text('Continue with Google'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() {
                                _isCreatingAccount = !_isCreatingAccount;
                                _errorMessage = null;
                              }),
                      child: Text(
                        _isCreatingAccount
                            ? 'Already have an account? Sign in'
                            : 'New to PalayPlan? Create an account',
                      ),
                    ),
                    if (widget.onContinueAsGuest != null) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : widget.onContinueAsGuest,
                        icon: const Icon(Icons.cloud_off_outlined),
                        label: Text(AppStrings.of(context).offlineGuest),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.of(context).offlineGuestHint,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF4A5568),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.shield_outlined),
                      label: Text(AppStrings.of(context).settingsPrivacy),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
