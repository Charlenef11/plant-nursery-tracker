
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const _forest = Color(0xFF285943);
const _sage = Color(0xFF91A98A);
const _cream = Color(0xFFF6F4EA);
const _dark = Color(0xFF26372D);
const _muted = Color(0xFF788276);
const _line = Color(0xFFE2E5D9);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _isCreatingAccount = false;
  bool _loading = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: _forest,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _switchMode() {
    setState(() {
      _isCreatingAccount = !_isCreatingAccount;
      _password.clear();
      _confirmPassword.clear();
      _formKey.currentState?.reset();
      _hidePassword = true;
      _hideConfirmPassword = true;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      if (_isCreatingAccount) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          message = 'Incorrect email or password.';
          break;
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email.';
          break;
        case 'weak-password':
          message = 'Password must be at least 6 characters.';
          break;
        case 'network-request-failed':
          message = 'Check your internet connection.';
          break;
        default:
          message = 'Something went wrong. Please try again.';
      }

      if (mounted) _showMessage(message);
    } catch (_) {
      if (mounted) {
        _showMessage('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  InputDecoration _decoration(
    String hint, {
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _muted, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _forest,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _dark,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('Email Address'),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _decoration(
              'Enter your email',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email.';
              }

              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                  .hasMatch(value.trim())) {
                return 'Please enter a valid email.';
              }

              return null;
            },
          ),

          const SizedBox(height: 20),

          _label('Password'),
          TextFormField(
            controller: _password,
            obscureText: _hidePassword,
            textInputAction: _isCreatingAccount
                ? TextInputAction.next
                : TextInputAction.done,
            decoration: _decoration(
              'Enter your password',
              suffix: IconButton(
                onPressed: () {
                  setState(() => _hidePassword = !_hidePassword);
                },
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _forest,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password.';
              }

              if (_isCreatingAccount && value.length < 6) {
                return 'At least 6 characters required.';
              }

              return null;
            },
            onFieldSubmitted: (_) {
              if (!_isCreatingAccount) _submit();
            },
          ),

          if (_isCreatingAccount) ...[
            const SizedBox(height: 20),
            _label('Confirm Password'),
            TextFormField(
              controller: _confirmPassword,
              obscureText: _hideConfirmPassword,
              textInputAction: TextInputAction.done,
              decoration: _decoration(
                'Confirm your password',
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      _hideConfirmPassword = !_hideConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _hideConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _forest,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password.';
                }

                if (value != _password.text) {
                  return 'Passwords do not match.';
                }

                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
          ],

          const SizedBox(height: 28),

          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: _forest,
                foregroundColor: _cream,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: _cream,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _isCreatingAccount ? 'CREATE ACCOUNT' : 'LOGIN',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  _isCreatingAccount
                      ? 'Already have an account?'
                      : "Don't have an account?",
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                  ),
                ),
              ),
              TextButton(
                onPressed: _loading ? null : _switchMode,
                child: Text(
                  _isCreatingAccount ? 'Login' : 'Create Account',
                  style: const TextStyle(
                    color: _forest,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.spa_outlined,
                    color: _forest,
                    size: 48,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'VERDANT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _forest,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    _isCreatingAccount
                        ? 'Create Account'
                        : 'Welcome Back',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _dark,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _isCreatingAccount
                        ? 'Start your own plant collection.'
                        : 'Sign in to manage your plants.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildForm(),

                  const SizedBox(height: 25),

                  const Divider(color: _line),

                  const SizedBox(height: 12),

                  const Text(
                    'PLANT NURSERY • BOTANICAL CARE TRACKER',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

