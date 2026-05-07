import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscure = true;
  bool _loading = false;

  static const _gold = Color(0xFFFFD21F);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final email = _emailController.text.trim();
    if (_nameController.text.trim().isEmpty ||
        !_isEmail(email) ||
        _passwordController.text.length < 6) {
      _message('Name, valid email and minimum 6 digit password required.');
      return;
    }
    setState(() => _loading = true);
    final ok = await _authService.signUpEmailOrLocal(
      email,
      _passwordController.text,
      name: _nameController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      _message('Signup failed. Email may already be registered.');
      return;
    }
    await context.read<ExpenseProvider>().reconnectCloudSync();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  bool _isEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020403),
      body: Stack(
        children: [
          Positioned(
            top: -140,
            right: -90,
            child: _glow(const Color(0xFFFFD21F), 310),
          ),
          Positioned(
            bottom: -120,
            left: -120,
            child: _glow(const Color(0xFF0EA5E9), 300),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton.filledTonal(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white.withValues(alpha: 0.07),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Create account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 26),
                            _field(
                              _nameController,
                              'Full name',
                              Icons.person_rounded,
                            ),
                            const SizedBox(height: 14),
                            _field(
                              _emailController,
                              'Email',
                              Icons.mail_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),
                            _field(
                              _passwordController,
                              'Password',
                              Icons.lock_rounded,
                              obscure: _obscure,
                              suffix: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: FilledButton.icon(
                                onPressed: _loading ? null : _create,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _gold,
                                  foregroundColor: Colors.black,
                                ),
                                icon: Icon(
                                  _loading
                                      ? Icons.hourglass_top_rounded
                                      : Icons.person_add_rounded,
                                ),
                                label: Text(
                                  _loading
                                      ? 'Creating account'
                                      : 'Create Account',
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
                                    color: _gold,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                label: const Text('Continue with Google'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        hintText: hint,
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

  Widget _glow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 120,
            spreadRadius: 54,
          ),
        ],
      ),
    );
  }
}
