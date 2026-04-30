import 'package:flutter/material.dart';
import '../widgets/auth_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _agreeTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowBackground(
        color1: const Color(0xFFFACC15), // Yellow
        color2: const Color(0xFF6366F1), // Indigo
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D110D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF27272A)),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(height: 20),
              
              const Text('Create\nAccount', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, height: 1.1, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Start managing your finances today.', style: TextStyle(color: Colors.grey[500])),
              
              const SizedBox(height: 28),
              
              buildLabel('FULL NAME'),
              buildTextField(hint: 'Nabil Masrur', icon: Icons.person_outline),
              const SizedBox(height: 16),

              buildLabel('EMAIL ADDRESS'),
              buildTextField(hint: 'nabil@example.com', icon: Icons.mail_outline),
              const SizedBox(height: 16),
              
              buildLabel('PASSWORD'),
              buildTextField(
                hint: '••••••••', 
                icon: Icons.lock_outline, 
                isPassword: true, 
                obscureText: _obscurePassword,
                onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Checkbox(
                    value: _agreeTerms,
                    onChanged: (val) => setState(() => _agreeTerms = val!),
                    activeColor: const Color(0xFFFACC15),
                    checkColor: Colors.black,
                  ),
                  Expanded(
                    child: Text('I agree to the Terms of Service & Privacy Policy.', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              buildPrimaryButton('Sign Up', Icons.person_add_outlined, () {
                Navigator.pop(context);
              }),
              
              const SizedBox(height: 24),
              buildDivider('OR SIGN UP WITH'),
              const SizedBox(height: 24),
              
              buildGoogleButton(isFullWidth: true),
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: TextStyle(color: Colors.grey[500])),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
