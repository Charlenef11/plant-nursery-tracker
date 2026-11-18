
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const _forest = Color(0xFF285943);
const _sage = Color(0xFF91A98A);
const _cream = Color(0xFFF6F4EA);
const _gold = Color(0xFFC5A66A);
const _dark = Color(0xFF26372D);
const _muted = Color(0xFF788276);
const _line = Color(0xFFE2E5D9);

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState
    extends State<AccountSettingsPage> {
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

  void _message(String message, {bool success = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
                color: _cream,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: _forest,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      _message('Please log in again.');
      return;
    }

    if (_currentPassword.text.isEmpty ||
        _newPassword.text.isEmpty) {
      _message('Please complete both password fields.');
      return;
    }

    if (_newPassword.text.length < 6) {
      _message('New password must have at least 6 characters.');
      return;
    }

    if (_currentPassword.text == _newPassword.text) {
      _message('Your new password must be different.');
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

      if (!mounted) return;

      setState(() {
        _showCurrentPassword = false;
        _showNewPassword = false;
      });

      _message('Your password has been changed!', success: true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect current password.';
          break;
        case 'weak-password':
          message = 'Please choose a stronger password.';
          break;
        case 'requires-recent-login':
          message = 'Please log in again before changing your password.';
          break;
        default:
          message = e.message ?? 'Unable to update password.';
      }

      _message(message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Leaving the garden?',
            style: TextStyle(
              color: _forest,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'You will be signed out of your Plant Nursery account.',
            style: TextStyle(color: _muted),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text(
                'Stay',
                style: TextStyle(color: _muted),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _forest,
                foregroundColor: _cream,
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final email = user?.email ?? 'No email available';
    final displayName = email.contains('@')
        ? email.split('@').first
        : 'Plant Keeper';

    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 750;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 48 : 22,
                vertical: 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PAGE HEADER
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VERDANT / PERSONAL SPACE',
                                style: TextStyle(
                                  color: _forest,
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'My account',
                                style: TextStyle(
                                  color: _dark,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: _forest,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.spa_outlined,
                              color: _cream,
                              size: 25,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // PROFILE INTRO
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(wide ? 30 : 22),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5EBDD),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: wide
                            ? Row(
                                children: [
                                  _profileAvatar(),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: _profileText(
                                      displayName,
                                      email,
                                    ),
                                  ),
                                  const Text(
                                    '01',
                                    style: TextStyle(
                                      color: _sage,
                                      fontSize: 48,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _profileAvatar(),
                                      const Spacer(),
                                      const Text(
                                        '01',
                                        style: TextStyle(
                                          color: _sage,
                                          fontSize: 42,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _profileText(displayName, email),
                                ],
                              ),
                      ),

                      const SizedBox(height: 34),

                      // ACCOUNT DETAILS
                      _sectionHeading(
                        number: '01',
                        title: 'Account details',
                        subtitle: 'Your registered information',
                      ),

                      const SizedBox(height: 16),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _line),
                        ),
                        child: Column(
                          children: [
                            _infoRow(
                              icon: Icons.alternate_email,
                              label: 'EMAIL ADDRESS',
                              value: email,
                            ),
                            const Divider(
                              height: 1,
                              indent: 18,
                              endIndent: 18,
                              color: _line,
                            ),
                            _infoRow(
                              icon: Icons.verified_user_outlined,
                              label: 'ACCOUNT STATUS',
                              value: user?.emailVerified == true
                                  ? 'Email verified'
                                  : 'Active account',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // PASSWORD SECTION
                      _sectionHeading(
                        number: '02',
                        title: 'Security garden',
                        subtitle: 'Keep your account protected',
                      ),

                      const SizedBox(height: 18),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(wide ? 28 : 20),
                        decoration: BoxDecoration(
                          color: _forest,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  color: _gold,
                                  size: 23,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'CHANGE PASSWORD',
                                  style: TextStyle(
                                    color: _cream,
                                    fontSize: 12,
                                    letterSpacing: 1.8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            const Text(
                              'A fresh password, a safer space.',
                              style: TextStyle(
                                color: _cream,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Confirm your current password before creating a new one.',
                              style: TextStyle(
                                color: _cream.withValues(alpha: 0.75),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 25),

                            _passwordField(
                              label: 'CURRENT PASSWORD',
                              controller: _currentPassword,
                              visible: _showCurrentPassword,
                              onToggle: () {
                                setState(() {
                                  _showCurrentPassword =
                                      !_showCurrentPassword;
                                });
                              },
                            ),

                            const SizedBox(height: 18),

                            _passwordField(
                              label: 'NEW PASSWORD',
                              controller: _newPassword,
                              visible: _showNewPassword,
                              onToggle: () {
                                setState(() {
                                  _showNewPassword =
                                      !_showNewPassword;
                                });
                              },
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'Minimum of 6 characters',
                              style: TextStyle(
                                color: _cream,
                                fontSize: 11,
                              ),
                            ),

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton(
                                onPressed:
                                    _loading ? null : _changePassword,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _gold,
                                  foregroundColor: _dark,
                                  disabledBackgroundColor: _gold,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(13),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 21,
                                        height: 21,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: _dark,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.key_outlined),
                                          SizedBox(width: 9),
                                          Text(
                                            'SAVE NEW PASSWORD',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // LOGOUT
                      _sectionHeading(
                        number: '03',
                        title: 'Sign out',
                        subtitle: 'Take a break from your garden',
                      ),

                      const SizedBox(height: 16),

                      InkWell(
                        onTap: _loading ? null : _confirmLogout,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 19,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0E8DD),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE5D8C5),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: Color(0xFF9A5945),
                                size: 23,
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Logout from account',
                                      style: TextStyle(
                                        color: _dark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Your garden will be here when you return.',
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: _muted,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.eco_outlined,
                              color: _sage,
                              size: 25,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'GROW AT YOUR OWN PACE',
                              style: TextStyle(
                                color: _forest,
                                fontSize: 10,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
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

                      const SizedBox(height: 20),
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

  Widget _profileAvatar() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: _forest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.person_outline_rounded,
        color: _cream,
        size: 43,
      ),
    );
  }

  Widget _profileText(String name, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YOUR PERSONAL GARDEN',
          style: TextStyle(
            color: _forest,
            fontSize: 9,
            letterSpacing: 1.7,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _dark,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          email,
          style: const TextStyle(
            color: _muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _sectionHeading({
    required String number,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            color: _gold,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _dark,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, color: _sage, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 9,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: _dark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _cream,
            fontSize: 10,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !visible,
          style: const TextStyle(
            color: _dark,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Enter $label'.toLowerCase(),
            hintStyle: const TextStyle(
              color: _muted,
              fontSize: 12,
            ),
            filled: true,
            fillColor: _cream,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                visible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: _forest,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: _gold,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
