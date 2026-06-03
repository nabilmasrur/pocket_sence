import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';

class AppColors {
  static const gold = Color(0xFFFFD21F);
  static const blue = Color(0xFF2563EB);
  static const ink = Color(0xFF020403);
  static const panel = Color(0xFF08110E);
  static const mint = Color(0xFF35E6A8);

  static bool isLight(BuildContext context) =>
      context.watch<ExpenseProvider>().themeMode == 'light';

  static Color background(BuildContext context) =>
      isLight(context) ? const Color(0xFFF7FAFF) : ink;

  static Color card(BuildContext context) =>
      isLight(context) ? Colors.white : panel.withValues(alpha: 0.76);

  static Color cardSoft(BuildContext context) => isLight(context)
      ? const Color(0xFFEFF6FF)
      : Colors.white.withValues(alpha: 0.06);

  static Color text(BuildContext context) =>
      isLight(context) ? const Color(0xFF0F172A) : Colors.white;

  static Color muted(BuildContext context) =>
      isLight(context) ? const Color(0xFF64748B) : Colors.white54;

  static Color border(BuildContext context) => isLight(context)
      ? const Color(0xFFD8E7FF)
      : Colors.white.withValues(alpha: 0.08);

  static Color accent(BuildContext context) => isLight(context) ? blue : gold;

  static Color nav(BuildContext context) => isLight(context)
      ? Colors.white.withValues(alpha: 0.94)
      : Colors.black.withValues(alpha: 0.74);
}
