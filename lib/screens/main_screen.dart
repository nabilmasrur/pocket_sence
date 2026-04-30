import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _activeTab = 0;
  final double budget = 5000.0;

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Drink': return '🍱';
      case 'Transport': return '🚲';
      case 'Shopping': return '👕';
      case 'Bills': return '🌐';
      default: return '💰';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food & Drink': return const Color(0xFFF97316);
      case 'Transport': return const Color(0xFF3B82F6);
      case 'Shopping': return const Color(0xFF10B981);
      case 'Bills': return const Color(0xFFA855F7);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        double totalSpent = provider.totalSpent;
        double remainingBudget = budget - totalSpent;
        double progress = (totalSpent / budget).clamp(0.0, 1.0);

        return Scaffold(
          backgroundColor: const Color(0xFF020502),
          body: Stack(
            children: [
              // Background Gradient Glow Effect
              Positioned(
                top: -100,
                left: 0,
                right: 0,
                height: 300,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF0A120A).withOpacity(0.8),
                        Colors.transparent,
                      ],
                      radius: 1.5,
                    ),
                  ),
                ),
              ),

              // Main Scrollable Content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildBalanceCard(totalSpent, remainingBudget, progress),
                      const SizedBox(height: 32),
                      const Text(
                        'Recent Expenses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildExpenseList(provider),
                    ],
                  ),
                ),
              ),

              // Custom Bottom Navigation Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomNav(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello, Nabil 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMMM d, yyyy').format(DateTime.now()),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF111411),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF27272A).withOpacity(0.5)),
          ),
          child: const Icon(
            Icons.person_outline,
            color: Colors.grey,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(double totalSpent, double remainingBudget, double progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D110D),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF27272A).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Text(
                    'TOTAL SPENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF27272A)),
                ),
                child: Text(
                  'Budget: ৳${budget.toInt()}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '৳',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFACC15),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                NumberFormat('#,##0.00').format(totalSpent),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.5,
                  color: Color(0xFFFACC15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF27272A))),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'REMAINING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      '৳${remainingBudget.toInt()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFACC15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF27272A),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFACC15)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(ExpenseProvider provider) {
    if (provider.expenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            "No expenses yet!",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }
    return Column(
      children: provider.expenses.map((expense) {
        return GestureDetector(
          onLongPress: () => _showActionDialog(context, expense, provider),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0D110D).withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF27272A).withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(expense.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _getCategoryIcon(expense.category),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${expense.category} • ${DateFormat('hh:mm a').format(expense.date)}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '- ৳${expense.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 85,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            border: Border(top: BorderSide(color: const Color(0xFF27272A).withOpacity(0.8))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_filled, 'Home', 0),
              _buildNavItem(Icons.bar_chart_rounded, 'Stats', 1),
              
              // Floating Action Button Style
              Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFACC15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFACC15).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _showExpenseSheet(context),
                      child: const Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),

              _buildNavItem(Icons.account_balance_wallet_outlined, 'Loans', 2),
              _buildNavItem(Icons.track_changes_outlined, 'Goals', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _activeTab == index;
    Color color = isActive ? const Color(0xFFFACC15) : Colors.grey[600]!;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showActionDialog(BuildContext context, Expense exp, ExpenseProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D110D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text("Edit"),
            onTap: () {
              Navigator.pop(context);
              _showExpenseSheet(context, expense: exp);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Delete"),
            onTap: () {
              provider.deleteExpense(exp.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showExpenseSheet(BuildContext context, {Expense? expense}) {
    final titleController = TextEditingController(text: expense?.title ?? "");
    final amountController = TextEditingController(text: expense?.amount.toString() ?? "");
    String selectedCategory = expense?.category ?? 'Food & Drink';
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D110D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Color(0xFFFACC15), fontSize: 24),
              decoration: const InputDecoration(hintText: "0.00", hintStyle: TextStyle(color: Colors.white24)),
            ),
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "Title", hintStyle: TextStyle(color: Colors.white24)),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedCategory,
              dropdownColor: const Color(0xFF0D110D),
              isExpanded: true,
              items: provider.budgetCategories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  // Re-building sheet state
                  Navigator.pop(context);
                  _showExpenseSheet(context, expense: expense); // A bit hacky, but works for quick sync
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  if (expense == null) {
                    provider.addExpense(titleController.text, double.parse(amountController.text), selectedCategory);
                  } else {
                    provider.updateExpense(expense.id, titleController.text, double.parse(amountController.text), selectedCategory);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
