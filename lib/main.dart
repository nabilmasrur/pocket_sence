import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // The app still runs locally when Firebase config is not present yet.
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ExpenseProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final light = provider.themeMode == 'light';
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pocket Sense',
          theme: ThemeData(
            brightness: light ? Brightness.light : Brightness.dark,
            scaffoldBackgroundColor: light
                ? const Color(0xFFF5F6F0)
                : const Color(0xFF020502),
            fontFamily: 'Inter',
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFFF6B000),
            inputDecorationTheme: const InputDecorationTheme(
              border: InputBorder.none,
            ),
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}

class AppTheme {
  static const ink = Color(0xFF020403);
  static const panel = Color(0xFF08110E);
  static const softPanel = Color(0xFF10211B);
  static const gold = Color(0xFFFFD21F);
  static const mint = Color(0xFF35E6A8);

  static BoxDecoration glass({double radius = 24}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.10),
          panel.withValues(alpha: 0.82),
        ],
      ),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.22),
          blurRadius: 28,
          offset: const Offset(0, 16),
        ),
      ],
    );
  }
}
