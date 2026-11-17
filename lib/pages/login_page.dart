import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color deepTeal = Color(0xFF164E52);
  static const Color champagne = Color(0xFFC9A875);
  static const Color cream = Color(0xFFF5F2E9);

  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _isCreatingAccount = false;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: champagne,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: cream,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: deepTeal,
        elevation: 6,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: champagne,
            width: 1,
          ),
        ),
      ),
    );
  }

  void _switchMode() {
    setState(() {
      _isCreatingAccount = !_isCreatingAccount;
      _password.clear();
      _confirmPassword.clear();
      _formKey.currentState?.reset();
      _obscurePassword = true;
      _obscureConfirmPassword = true;
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
          message = 'Incorrect email or password. Please try again.';
          break;
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Password must be at least 6 characters.';
          break;
        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;
        default:
          message = _isCreatingAccount
              ? 'Unable to create account. Please try again.'
              : 'Unable to log in. Please try again.';
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

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: deepTeal,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: champagne,
        size: 21,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: cream,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: champagne),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: champagne.withValues(alpha: 0.7),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: deepTeal,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Email Address'),
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            hint: 'Enter your email',
            icon: Icons.email_outlined,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email.';
            }

            if (!RegExp(
              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
            ).hasMatch(value.trim())) {
              return 'Please enter a valid email address.';
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Password'),
        TextFormField(
          controller: _password,
          obscureText: _obscurePassword,
          textInputAction: _isCreatingAccount
              ? TextInputAction.next
              : TextInputAction.done,
          decoration: _inputDecoration(
            hint: 'Enter your password',
            icon: Icons.lock_outline,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: deepTeal,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password.';
            }

            if (_isCreatingAccount && value.length < 6) {
              return 'Password must be at least 6 characters.';
            }

            return null;
          },
          onFieldSubmitted: (_) {
            if (!_isCreatingAccount) _submit();
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Confirm Password'),
        TextFormField(
          controller: _confirmPassword,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          decoration: _inputDecoration(
            hint: 'Re-enter your password',
            icon: Icons.lock_outline,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword =
                      !_obscureConfirmPassword;
                });
              },
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: deepTeal,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardPadding = screenWidth > 500 ? 36.0 : 24.0;

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: const Text(
          'Student Information App',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: deepTeal,
        foregroundColor: cream,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 460,
            ),
            child: Card(
              color: cream,
              elevation: 4,
              shadowColor: deepTeal.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(
                  color: champagne,
                  width: 1.2,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          height: 88,
                          width: 88,
                          decoration: BoxDecoration(
                            color: deepTeal,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: champagne,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _isCreatingAccount
                                ? Icons.person_add_alt_1_rounded
                                : Icons.school_rounded,
                            color: champagne,
                            size: 44,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        _isCreatingAccount
                            ? 'Create Account'
                            : 'Welcome Back!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: deepTeal,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        _isCreatingAccount
                            ? 'Create an account to access your student information.'
                            : 'Sign in to access your student information.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      _buildEmailField(),

                      const SizedBox(height: 20),

                      _buildPasswordField(),

                      if (_isCreatingAccount) ...[
                        const SizedBox(height: 20),
                        _buildConfirmPasswordField(),
                      ],

                      const SizedBox(height: 28),

                      SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: deepTeal,
                            foregroundColor: cream,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: cream,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isCreatingAccount
                                          ? 'Create Account'
                                          : 'Login',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                                  ],
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
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _loading ? null : _switchMode,
                            child: Text(
                              _isCreatingAccount
                                  ? 'Login'
                                  : 'Create Account',
                              style: const TextStyle(
                                color: deepTeal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      const Divider(color: champagne),

                      const SizedBox(height: 12),

                      const Text(
                        'STUDENT INFORMATION SYSTEM',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: deepTeal,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

