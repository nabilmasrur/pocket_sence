import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';
import 'loans_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _activeTab = 0;

  static const _ink = Color(0xFF020403);
  static const _panel = Color(0xFF08110E);
  static const _gold = Color(0xFFFFD21F);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: _ink,
          body: Stack(
            children: [
              const _AuroraBackground(),
              IndexedStack(
                index: _activeTab,
                children: const [
                  _HomeDashboard(),
                  StatsScreen(),
                  LoansScreen(),
                  SettingsScreen(),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _bottomNav(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bottomNav(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          height: 92,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.74),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(Icons.home_rounded, 'Home', 0),
              _navItem(Icons.pie_chart_rounded, 'Stats', 1),
              _fab(context),
              _navItem(Icons.account_balance_wallet_rounded, 'Loans', 2),
              _navItem(Icons.settings_rounded, 'Settings', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final active = _activeTab == index;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeTab = index);
      },
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 58,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? _gold : Colors.white54),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: active ? _gold : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fab(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -22),
      child: GestureDetector(
        onTap: () => _showExpenseSheet(context),
        child: Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _gold,
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.58),
                blurRadius: 32,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.black, size: 34),
        ),
      ),
    );
  }

  static Future<void> _showExpenseSheet(
    BuildContext context, {
    Expense? expense,
  }) async {
    final provider = context.read<ExpenseProvider>();
    final title = TextEditingController(text: expense?.title ?? '');
    final amount = TextEditingController(
      text: expense == null ? '' : expense.amount.toStringAsFixed(0),
    );
    final newCategory = TextEditingController();
    var category = expense?.category ?? provider.budgetCategories.first;
    var date = expense?.date ?? DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                MediaQuery.of(context).viewInsets.bottom + 22,
              ),
              decoration: const BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    expense == null ? 'Add Expense' : 'Edit Expense',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sheetField(title, 'Title', Icons.edit_note_rounded),
                  const SizedBox(height: 12),
                  _sheetField(
                    amount,
                    'Amount',
                    Icons.payments_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.budgetCategories.map((item) {
                      final active = category == item;
                      return ChoiceChip(
                        label: Text(item),
                        selected: active,
                        selectedColor: _gold,
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                        labelStyle: TextStyle(
                          color: active ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                        side: BorderSide(
                          color: active
                              ? _gold
                              : Colors.white.withValues(alpha: 0.08),
                        ),
                        onSelected: (_) => setSheetState(() => category = item),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _sheetField(
                          newCategory,
                          'New category',
                          Icons.category_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        onPressed: () async {
                          await provider.addCategory(newCategory.text);
                          if (newCategory.text.trim().isNotEmpty) {
                            setSheetState(() {
                              category = newCategory.text.trim();
                              newCategory.clear();
                            });
                          }
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: _gold,
                          foregroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_today_rounded,
                      color: _gold,
                    ),
                    title: Text(
                      DateFormat('EEE, MMM d, yyyy').format(date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                        initialDate: date,
                      );
                      if (picked != null) setSheetState(() => date = picked);
                    },
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final parsed = double.tryParse(amount.text.trim());
                        if (title.text.trim().isEmpty || parsed == null) {
                          return;
                        }
                        if (expense == null) {
                          await provider.addExpense(
                            title.text.trim(),
                            parsed,
                            category,
                            date: date,
                          );
                        } else {
                          await provider.updateExpense(
                            expense.id,
                            title.text.trim(),
                            parsed,
                            category,
                          );
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _sheetField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: _gold),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  static const _panel = Color(0xFF08110E);
  static const _gold = Color(0xFFFFD21F);
  static const _mint = Color(0xFF35E6A8);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final todaySpent = provider.todaySpent;
    final limit = provider.dynamicDailyLimit;
    final progress = limit <= 0 ? 0.0 : (todaySpent / limit).clamp(0.0, 1.0);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 112),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(provider.isCloudConnected),
            const SizedBox(height: 24),
            _summaryCard(provider, progress),
            const SizedBox(height: 18),
            _smallCards(provider),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Expenses",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${provider.expensesOn(DateTime.now()).length} items',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _expenseList(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _header(bool cloud) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Flexible(
                    child: Text(
                      'Hello, Nabil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.waving_hand_rounded, color: _gold),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, MMM d').format(DateTime.now()),
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 28,
          backgroundColor: _gold,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                'N',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 2,
                child: CircleAvatar(
                  radius: 6,
                  backgroundColor: cloud ? _mint : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(ExpenseProvider provider, double progress) {
    final left = (provider.dynamicDailyLimit - provider.todaySpent).clamp(
      0,
      provider.dynamicDailyLimit,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.12),
                _panel.withValues(alpha: 0.88),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _pill(
                    'Daily limit',
                    'BDT ${provider.dynamicDailyLimit.toStringAsFixed(0)}',
                  ),
                  _pill('Left', 'BDT ${left.toStringAsFixed(0)}'),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Spent today',
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 6),
              Text(
                'BDT ${NumberFormat('#,##0').format(provider.todaySpent)}',
                style: const TextStyle(
                  color: _gold,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  backgroundColor: Colors.white12,
                  color: _gold,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                provider.smartTip,
                style: const TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallCards(ExpenseProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _mini(
            'This month',
            'BDT ${provider.thisMonthSpent.toStringAsFixed(0)}',
            Icons.calendar_month_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _mini(
            'Health',
            '${provider.financialHealthScore}/100',
            Icons.favorite_rounded,
          ),
        ),
      ],
    );
  }

  Widget _mini(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _gold),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.white54)),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _expenseList(BuildContext context, ExpenseProvider provider) {
    final today = provider.expensesOn(DateTime.now());
    if (today.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: const Column(
          children: [
            Icon(Icons.receipt_long_rounded, color: Colors.white54, size: 52),
            SizedBox(height: 12),
            Text(
              'No expenses today',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tap + to add a record',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return Column(
      children: today.map((expense) {
        final color = _categoryColor(expense.category);
        return Dismissible(
          key: ValueKey(expense.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.redAccent),
          ),
          onDismissed: (_) => provider.deleteExpense(expense.id),
          child: InkWell(
            onTap: () =>
                _MainScreenState._showExpenseSheet(context, expense: expense),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_categoryIcon(expense.category), color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${expense.category} - ${DateFormat('h:mm a').format(expense.date)}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '-BDT ${expense.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Food & Drink':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_bus_filled_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Education':
        return Icons.school_rounded;
      case 'Health':
        return Icons.local_hospital_rounded;
      default:
        return Icons.savings_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Food & Drink':
        return const Color(0xFFFF8A3D);
      case 'Transport':
        return const Color(0xFF54A3FF);
      case 'Shopping':
        return _mint;
      case 'Bills':
        return const Color(0xFFB777FF);
      case 'Education':
        return const Color(0xFFFFD21F);
      case 'Health':
        return const Color(0xFFFF5C7A);
      default:
        return const Color(0xFF9CA3AF);
    }
  }
}

class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFF020403)),
        Positioned(
          top: -140,
          right: -120,
          child: _glow(const Color(0xFFFFD21F), 290, 0.16),
        ),
        Positioned(
          top: 150,
          left: -150,
          child: _glow(const Color(0xFF35E6A8), 340, 0.11),
        ),
      ],
    );
  }

  Widget _glow(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: 120,
            spreadRadius: 55,
          ),
        ],
      ),
    );
  }
}
