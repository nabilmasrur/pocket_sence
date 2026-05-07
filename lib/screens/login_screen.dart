import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _loading = false;

  static const _gold = Color(0xFFFFD21F);
  static const _ink = Color(0xFF020403);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    if (!_isEmail(email) || _passwordController.text.length < 6) {
      _message('Enter a valid email and minimum 6 digit password.');
      return;
    }

    setState(() => _loading = true);
    final ok = await _authService.signInEmailOrLocal(
      email,
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      _message('Sign in failed. Create account first or check password.');
      return;
    }

    await context.read<ExpenseProvider>().reconnectCloudSync();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    final ok = await _authService.signInGoogleOrLocal();
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      _message('Google sign in cancelled.');
      return;
    }
    await context.read<ExpenseProvider>().reconnectCloudSync();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  Future<void> _resetPassword() async {
    final sent = await _authService.sendPasswordReset(
      _emailController.text.trim(),
    );
    _message(
      sent ? 'Password reset email sent.' : 'Enter a valid email first.',
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  bool _isEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ink,
      body: Stack(
        children: [
          const _AuthGlow(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: _glass(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _brand(),
                          const SizedBox(height: 26),
                          _field(
                            controller: _emailController,
                            hint: 'Email',
                            icon: Icons.mail_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),
                          _field(
                            controller: _passwordController,
                            hint: 'Password',
                            icon: Icons.lock_rounded,
                            obscureText: _obscurePassword,
                            suffix: IconButton(
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _resetPassword,
                              child: const Text('Forgot password?'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton.icon(
                              onPressed: _loading ? null : _signIn,
                              style: FilledButton.styleFrom(
                                backgroundColor: _gold,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              icon: Icon(
                                _loading
                                    ? Icons.hourglass_top_rounded
                                    : Icons.arrow_forward_rounded,
                              ),
                              label: Text(
                                _loading ? 'Please wait' : 'Sign In',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: _loading ? null : _googleSignIn,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              icon: const Text(
                                'G',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: _gold,
                                ),
                              ),
                              label: const Text('Continue with Google'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'New to Pocket Sense? ',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.52),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignUpScreen(),
                                  ),
                                ),
                                child: const Text(
                                  'Create account',
                                  style: TextStyle(
                                    color: _gold,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _brand() {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: _gold,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: _gold.withValues(alpha: 0.38), blurRadius: 28),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pocket Sense',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Smart expense tracker',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.34)),
        prefixIcon: Icon(icon, color: _gold),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  BoxDecoration _glass() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.12),
          const Color(0xFF08110E).withValues(alpha: 0.88),
        ],
      ),
      border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
    );
  }
}

class _AuthGlow extends StatelessWidget {
  const _AuthGlow();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -120,
          right: -100,
          child: _glow(const Color(0xFFFFD21F), 300),
        ),
        Positioned(
          bottom: -140,
          left: -120,
          child: _glow(const Color(0xFF35E6A8), 320),
        ),
      ],
    );
  }

  Widget _glow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.16),
            blurRadius: 120,
            spreadRadius: 58,
          ),
        ],
      ),
    );
  }
}
