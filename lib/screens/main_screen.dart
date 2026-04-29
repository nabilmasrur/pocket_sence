import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String getFormattedDate() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${now.day} ${months[now.month - 1]}, ${now.year}";
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Drink': return Icons.coffee_rounded;
      case 'Transport': return Icons.directions_bus_rounded;
      case 'Shopping': return Icons.shopping_bag_rounded;
      case 'Bills': return Icons.receipt_long_rounded;
      default: return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF020807),
          body: Stack(
            children: [
              _buildBackgroundGlows(),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    _buildHeroCard(provider),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        "Recent Expenses",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: provider.expenses.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
                              itemCount: provider.expenses.length,
                              itemBuilder: (context, index) {
                                final exp = provider.expenses[index];
                                return _buildExpenseTile(context, exp, provider);
                              },
                            ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildBottomNav(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundGlows() {
    return Stack(
      children: [
        Positioned(
          top: -150,
          left: -150,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [const Color(0xFF0A2E28).withOpacity(0.6), Colors.transparent],
                stops: const [0.2, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          right: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [const Color(0xFFF6B000).withOpacity(0.12), Colors.transparent],
                stops: const [0.2, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, Nabil 👋",
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                getFormattedDate(),
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => _showProfileDialog(context),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Center(child: Icon(Icons.person, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(ExpenseProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_rounded, size: 18, color: Colors.white.withOpacity(0.8)),
                    const SizedBox(width: 8),
                    Text(
                      "Total Spent",
                      style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.9), fontSize: 14),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    "Budget: ৳5000",
                    style: GoogleFonts.outfit(fontSize: 10, color: Colors.white.withOpacity(0.8)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "৳ ${provider.totalSpent.toStringAsFixed(2)}",
              style: GoogleFonts.outfit(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFF6B000),
                shadows: [Shadow(color: const Color(0xFFF6B000).withOpacity(0.4), blurRadius: 10)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 60, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 10),
          Text("No expenses yet!", style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.5), fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildExpenseTile(BuildContext context, Expense exp, ExpenseProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onLongPress: () => _showActionDialog(context, exp, provider),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.15)),
              left: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(getCategoryIcon(exp.category), color: Colors.white.withOpacity(0.9), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exp.title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(exp.category, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                  ],
                ),
              ),
              Text("-৳ ${exp.amount.toStringAsFixed(0)}", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 85,
          decoration: BoxDecoration(
            color: const Color(0xFF030A09).withOpacity(0.95),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, "Home", isActive: true),
              _navItem(Icons.bar_chart_rounded, "Stats"),
              const SizedBox(width: 40),
              _navItem(Icons.account_balance_wallet_rounded, "Loans"),
              _navItem(Icons.track_changes_rounded, "Goals"),
            ],
          ),
        ),
        Positioned(
          top: -25,
          child: InkWell(
            onTap: () => _showExpenseSheet(context),
            borderRadius: BorderRadius.circular(35),
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFFF6B000).withOpacity(0.3), blurRadius: 20, spreadRadius: 2)],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A1A1A),
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                  gradient: RadialGradient(colors: [Colors.white.withOpacity(0.2), Colors.transparent], radius: 0.8),
                ),
                child: const Icon(Icons.add_rounded, color: Color(0xFFF6B000), size: 32),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _navItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? const Color(0xFFF6B000) : Colors.white.withOpacity(0.5), size: 24),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.outfit(fontSize: 10, color: isActive ? const Color(0xFFF6B000) : Colors.white.withOpacity(0.5), fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  void _showProfileDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF051412),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 16),
            Text("Nabil Masrur", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            Text("Offline Mode Active", style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.5))),
            const Divider(height: 40, color: Colors.white10),
            ListTile(
              leading: const Icon(Icons.security_rounded, color: Color(0xFFF6B000)),
              title: Text("App Lock", style: GoogleFonts.outfit(color: Colors.white)),
              trailing: Switch(value: true, onChanged: (v) {}, activeColor: const Color(0xFFF6B000)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showActionDialog(BuildContext context, Expense exp, ExpenseProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF051412),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.15))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Text(exp.title, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: Colors.blueAccent),
              title: Text("Edit Expense", style: GoogleFonts.outfit(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showExpenseSheet(context, expense: exp);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.redAccent),
              title: Text("Delete Expense", style: GoogleFonts.outfit(color: Colors.white)),
              onTap: () async {
                await provider.deleteExpense(exp.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
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
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF020807).withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.3))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 24),
                Text(expense == null ? "New Expense" : "Edit Expense", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFFF6B000)),
                  decoration: InputDecoration(
                    prefixText: "৳ ",
                    prefixStyle: GoogleFonts.outfit(fontSize: 32, color: const Color(0xFFF6B000).withOpacity(0.5)),
                    hintText: "0.00",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "What was this for?",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: provider.budgetCategories.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat, style: GoogleFonts.outfit(color: isSelected ? Colors.black : Colors.white.withOpacity(0.8))),
                      selected: isSelected,
                      selectedColor: const Color(0xFFF6B000),
                      backgroundColor: Colors.white.withOpacity(0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.2))),
                      onSelected: (val) {
                        setSheetState(() => selectedCategory = cat);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFD49800), Color(0xFFF6B000)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFFF6B000).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                      onPressed: () async {
                        if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                          if (expense == null) {
                            await provider.addExpense(titleController.text, double.parse(amountController.text), selectedCategory);
                          } else {
                            await provider.updateExpense(expense.id, titleController.text, double.parse(amountController.text), selectedCategory);
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: Text(expense == null ? "Save Expense" : "Update Expense", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF020807))),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
