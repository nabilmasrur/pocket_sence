import 'package:flutter/material.dart';
import '../widgets/auth_widgets.dart';
import 'signup_screen.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowBackground(
        color1: const Color(0xFFFACC15), // Yellow
        color2: const Color(0xFF10B981), // Emerald
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Logo
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D110D),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF27272A)),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFACC15).withOpacity(0.1), blurRadius: 20)
                  ],
                ),
                alignment: Alignment.center,
                child: const Text('💰', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(height: 24),
              const Text('Welcome\nBack!', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, height: 1.1, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Sign in to manage your finances seamlessly.', style: TextStyle(color: Colors.grey[500])),
              
              const SizedBox(height: 32),
              
              buildLabel('EMAIL ADDRESS'),
              buildTextField(hint: 'nabil@example.com', icon: Icons.mail_outline),
              const SizedBox(height: 20),
              
              buildLabel('PASSWORD'),
              buildTextField(
                hint: '••••••••', 
                icon: Icons.lock_outline, 
                isPassword: true, 
                obscureText: _obscurePassword,
                onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFFFACC15), fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 20),
              buildPrimaryButton('Sign In', Icons.arrow_forward, () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
              }),
              
              const SizedBox(height: 24),
              buildDivider('OR CONTINUE WITH'),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(child: buildGoogleButton()),
                  const SizedBox(width: 16),
                  Expanded(child: buildBiometricButton()),
                ],
              ),
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: TextStyle(color: Colors.grey[500])),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                    child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
