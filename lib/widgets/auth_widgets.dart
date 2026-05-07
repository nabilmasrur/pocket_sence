import 'package:flutter/material.dart';

// ==========================================
// BACKGROUND GLOW HELPER
// ==========================================
class GlowBackground extends StatelessWidget {
  final Widget child;
  final Color color1;
  final Color color2;

  const GlowBackground({
    super.key,
    required this.child,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: -50, right: -50, child: _buildGlow(color1)),
        Positioned(bottom: -50, left: -50, child: _buildGlow(color2)),
        SafeArea(child: child),
      ],
    );
  }

  Widget _buildGlow(Color color) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 100,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}

// ==========================================
// REUSABLE AUTH WIDGETS
// ==========================================

Widget buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey[500],
        letterSpacing: 1.2,
      ),
    ),
  );
}

Widget buildTextField({
  required String hint,
  required IconData icon,
  bool isPassword = false,
  bool obscureText = false,
  VoidCallback? onToggle,
  TextEditingController? controller,
  TextInputType? keyboardType,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[600]),
      filled: true,
      fillColor: const Color(0xFF0D110D),
      prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[500],
                size: 20,
              ),
              onPressed: onToggle,
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF27272A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF27272A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFACC15)),
      ),
    ),
  );
}

Widget buildPrimaryButton(String text, IconData icon, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFFACC15),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFACC15).withValues(alpha: 0.2),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.black, size: 20),
        ],
      ),
    ),
  );
}

Widget buildDivider(String text) {
  return Row(
    children: [
      Expanded(child: Divider(color: Colors.grey[800])),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Expanded(child: Divider(color: Colors.grey[800])),
    ],
  );
}

Widget buildGoogleButton({bool isFullWidth = false, VoidCallback? onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      width: isFullWidth ? double.infinity : null,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'G',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isFullWidth ? 'Continue with Google' : 'Google',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildBiometricButton({VoidCallback? onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF0D110D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fingerprint, color: Color(0xFFFACC15), size: 20),
          SizedBox(width: 8),
          Text(
            'Biometric',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
