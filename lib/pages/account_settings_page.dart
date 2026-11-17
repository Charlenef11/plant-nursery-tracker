import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const deepTeal = Color(0xFF164E52);
const champagne = Color(0xFFC9A875);
const cream = Color(0xFFF5F2E9);

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();

  bool _loading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  void _showSnackBar({
    required String message,
    required bool isSuccess,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: deepTeal,
          elevation: 6,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: champagne,
              width: 1,
            ),
          ),
          content: Row(
            children: [
              Icon(
                isSuccess
                    ? Icons.check_circle_rounded
                    : Icons.error_outline_rounded,
                color: champagne,
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: cream,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) return;

    if (_currentPassword.text.isEmpty ||
        _newPassword.text.length < 6) {
      _showSnackBar(
        message:
            'Enter your current password and a new password of at least 6 characters.',
        isSuccess: false,
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPassword.text,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPassword.text);

      _currentPassword.clear();
      _newPassword.clear();

      if (mounted) {
        setState(() {
          _showCurrentPassword = false;
          _showNewPassword = false;
        });

        _showSnackBar(
          message: 'Password updated successfully!',
          isSuccess: true,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage;

        switch (e.code) {
          case 'wrong-password':
          case 'invalid-credential':
            errorMessage =
                'Incorrect current password. Please try again.';
            break;
          case 'weak-password':
            errorMessage =
                'Please choose a stronger password.';
            break;
          case 'requires-recent-login':
            errorMessage =
                'Please log in again before changing your password.';
            break;
          default:
            errorMessage =
                e.message ?? 'Password update failed.';
        }

        _showSnackBar(
          message: errorMessage,
          isSuccess: false,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Account Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isWide ? 32 : 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Account information
                      Container(
                        padding: EdgeInsets.all(isWide ? 30 : 22),
                        decoration: BoxDecoration(
                          color: deepTeal,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: champagne,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 82,
                              height: 82,
                              decoration: BoxDecoration(
                                color: champagne,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: deepTeal,
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Account Information',
                              style: TextStyle(
                                color: cream,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Your registered account',
                              style: TextStyle(
                                color: cream,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: cream,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.email_outlined,
                                    color: deepTeal,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      user.email ?? 'Unknown',
                                      style: const TextStyle(
                                        color: deepTeal,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Change password section
                      Card(
                        color: cream,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                          side: const BorderSide(color: champagne),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isWide ? 28 : 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.lock_reset_rounded,
                                    color: deepTeal,
                                    size: 28,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Change Password',
                                      style: TextStyle(
                                        color: deepTeal,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              const Text(
                                'Update your password to keep your account secure.',
                                style: TextStyle(
                                  color: deepTeal,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Current Password
                              TextField(
                                controller: _currentPassword,
                                obscureText: !_showCurrentPassword,
                                decoration: InputDecoration(
                                  labelText: 'Current Password',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: champagne,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _showCurrentPassword =
                                            !_showCurrentPassword;
                                      });
                                    },
                                    icon: Icon(
                                      _showCurrentPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: deepTeal,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: cream,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: champagne,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: champagne,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: deepTeal,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // New Password
                              TextField(
                                controller: _newPassword,
                                obscureText: !_showNewPassword,
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                  helperText: 'At least 6 characters',
                                  prefixIcon: const Icon(
                                    Icons.lock_reset_rounded,
                                    color: champagne,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _showNewPassword =
                                            !_showNewPassword;
                                      });
                                    },
                                    icon: Icon(
                                      _showNewPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: deepTeal,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: cream,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: champagne,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: champagne,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: deepTeal,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              SizedBox(
                                height: 52,
                                child: FilledButton.icon(
                                  onPressed: _loading
                                      ? null
                                      : _changePassword,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: deepTeal,
                                    foregroundColor: cream,
                                    disabledBackgroundColor: deepTeal,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: _loading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: cream,
                                          ),
                                        )
                                      : const Icon(Icons.save_rounded),
                                  label: Text(
                                    _loading
                                        ? 'Updating...'
                                        : 'Update Password',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Logout section
                      OutlinedButton.icon(
                        onPressed: _loading
                            ? null
                            : () async {
                                await FirebaseAuth.instance.signOut();
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: deepTeal,
                          side: const BorderSide(
                            color: champagne,
                            width: 1.5,
                          ),
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

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
            );
          },
        ),
      ),
    );
  }
}

