import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  final List<String> budgetCategories = ['Food & Drink', 'Transport', 'Shopping', 'Bills', 'Others'];

  List<Expense> get expenses => _expenses;

  double get totalSpent {
    return _expenses.fold(0, (sum, item) => sum + item.amount);
  }

  ExpenseProvider() {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? expensesString = prefs.getString('saved_expenses');
      if (expensesString != null) {
        final List<dynamic> decoded = json.decode(expensesString);
        _expenses = decoded.map((item) => Expense.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      _expenses = [];
      notifyListeners();
    }
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_expenses.map((e) => e.toJson()).toList());
    await prefs.setString('saved_expenses', encoded);
  }

  Future<void> addExpense(String title, double amount, String category) async {
    final newExpense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: category,
      date: DateTime.now(),
    );
    _expenses.insert(0, newExpense);
    _saveExpenses();
    notifyListeners();
  }

  Future<void> updateExpense(String id, String title, double amount, String category) async {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      _expenses[index] = Expense(
        id: id,
        title: title,
        amount: amount,
        category: category,
        date: _expenses[index].date,
      );
      _saveExpenses();
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((expense) => expense.id == id);
    _saveExpenses();
    notifyListeners();
  }
}
