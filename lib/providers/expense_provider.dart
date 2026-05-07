import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/budget_engine.dart';
import '../core/health_score.dart';
import '../core/prediction_engine.dart';
import '../models/debt_entry.dart';
import '../models/expense.dart';
import '../models/goal.dart';
import '../services/firestore_service.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  List<DebtEntry> _debts = [];
  List<Goal> _goals = [
    const Goal(
      id: 'goal-default',
      name: 'Emergency Fund',
      targetAmount: 50000,
      savedAmount: 12000,
    ),
  ];
  List<String> _budgetCategories = [
    'Food & Drink',
    'Transport',
    'Shopping',
    'Bills',
    'Education',
    'Health',
    'Others',
  ];
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<Expense>>? _expenseSubscription;
  StreamSubscription<List<DebtEntry>>? _debtSubscription;
  bool _isCloudConnected = false;
  String _smartTip = 'Track today clearly and keep spending under control.';
  String _themeMode = 'default';
  double _monthlyBudget = 30000;
  double _dailyBudget = 1000;
  double _weeklyBudget = 7000;
  double _yearlyBudget = 360000;
  TimeOfDay? _dailyAlarmTime;

  List<Expense> get expenses => _expenses;
  List<DebtEntry> get debts => _debts;
  List<Goal> get goals => _goals;
  List<String> get budgetCategories => List.unmodifiable(_budgetCategories);
  bool get isCloudConnected => _isCloudConnected;
  String get smartTip => _smartTip;
  String get themeMode => _themeMode;
  double get monthlyBudget => _monthlyBudget;
  double get dailyBudget => _dailyBudget;
  double get weeklyBudget => _weeklyBudget;
  double get yearlyBudget => _yearlyBudget;
  TimeOfDay? get dailyAlarmTime => _dailyAlarmTime;
  double get dynamicDailyLimit => BudgetEngine.dynamicDailyLimit(
    expenses: _expenses,
    monthlyBudget: _monthlyBudget,
  );
  double get todaySpent => BudgetEngine.todaySpent(_expenses);
  double get predictedMonthlyBill =>
      PredictionEngine.predictedMonthlyBill(_expenses);
  int get financialHealthScore =>
      HealthScore.calculate(expenses: _expenses, monthlyBudget: _monthlyBudget);
  Goal get primaryGoal => _goals.first;

  double get totalSpent {
    return _expenses.fold(0, (sum, item) => sum + item.amount);
  }

  double get thisMonthSpent {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double spentOn(DateTime date) {
    return _expenses
        .where(
          (e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day,
        )
        .fold(0, (sum, item) => sum + item.amount);
  }

  List<Expense> expensesOn(DateTime date) {
    return _expenses
        .where(
          (e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day,
        )
        .toList();
  }

  ExpenseProvider() {
    _loadExpenses();
    _connectCloudSync();
  }

  Future<void> reconnectCloudSync() => _connectCloudSync();

  Future<void> _connectCloudSync() async {
    try {
      await _expenseSubscription?.cancel();
      await _debtSubscription?.cancel();
      _expenseSubscription = _firestoreService.getExpenses().listen((
        cloudExpenses,
      ) {
        if (cloudExpenses.isEmpty) return;
        _isCloudConnected = true;
        _expenses = cloudExpenses;
        _saveExpenses();
        notifyListeners();
      });
      _debtSubscription = _firestoreService.getDebts().listen((cloudDebts) {
        if (cloudDebts.isEmpty) return;
        _isCloudConnected = true;
        _debts = cloudDebts;
        _saveExpenses();
        notifyListeners();
      });
    } catch (_) {
      _isCloudConnected = false;
    }
  }

  Future<void> _loadExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? expensesString = prefs.getString('saved_expenses');
      final String? debtsString = prefs.getString('saved_debts');
      final String? goalsString = prefs.getString('saved_goals');
      final String? categoriesString = prefs.getString('saved_categories');
      _monthlyBudget = prefs.getDouble('monthly_budget') ?? _monthlyBudget;
      _dailyBudget = prefs.getDouble('daily_budget') ?? _dailyBudget;
      _weeklyBudget = prefs.getDouble('weekly_budget') ?? _weeklyBudget;
      _yearlyBudget = prefs.getDouble('yearly_budget') ?? _yearlyBudget;
      _themeMode = prefs.getString('theme_mode') ?? _themeMode;
      final alarmHour = prefs.getInt('daily_alarm_hour');
      final alarmMinute = prefs.getInt('daily_alarm_minute');
      if (alarmHour != null && alarmMinute != null) {
        _dailyAlarmTime = TimeOfDay(hour: alarmHour, minute: alarmMinute);
      }
      if (expensesString != null) {
        final List<dynamic> decoded = json.decode(expensesString);
        _expenses = decoded.map((item) => Expense.fromJson(item)).toList();
      }
      if (debtsString != null) {
        final List<dynamic> decoded = json.decode(debtsString);
        _debts = decoded.map((item) => DebtEntry.fromJson(item)).toList();
      }
      if (goalsString != null) {
        final List<dynamic> decoded = json.decode(goalsString);
        _goals = decoded.map((item) => Goal.fromJson(item)).toList();
      }
      if (categoriesString != null) {
        final List<dynamic> decoded = json.decode(categoriesString);
        _budgetCategories = decoded.map((item) => item.toString()).toList();
      }
      notifyListeners();
      _refreshSmartTip();
    } catch (e) {
      _expenses = [];
      notifyListeners();
    }
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(
      _expenses.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('saved_expenses', encoded);
    await prefs.setString(
      'saved_debts',
      json.encode(_debts.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      'saved_goals',
      json.encode(_goals.map((e) => e.toJson()).toList()),
    );
    await prefs.setString('saved_categories', json.encode(_budgetCategories));
    await prefs.setDouble('monthly_budget', _monthlyBudget);
    await prefs.setDouble('daily_budget', _dailyBudget);
    await prefs.setDouble('weekly_budget', _weeklyBudget);
    await prefs.setDouble('yearly_budget', _yearlyBudget);
    await prefs.setString('theme_mode', _themeMode);
    if (_dailyAlarmTime != null) {
      await prefs.setInt('daily_alarm_hour', _dailyAlarmTime!.hour);
      await prefs.setInt('daily_alarm_minute', _dailyAlarmTime!.minute);
    }
  }

  Future<void> setBudgets({
    double? daily,
    double? weekly,
    double? monthly,
    double? yearly,
  }) async {
    if (daily != null) _dailyBudget = daily.clamp(0, 10000000);
    if (weekly != null) _weeklyBudget = weekly.clamp(0, 10000000);
    if (monthly != null) _monthlyBudget = monthly.clamp(1000, 10000000);
    if (yearly != null) _yearlyBudget = yearly.clamp(0, 100000000);
    await _saveExpenses();
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double value) async {
    _monthlyBudget = value.clamp(1000, 1000000);
    await _saveExpenses();
    notifyListeners();
  }

  Future<void> setThemeMode(String value) async {
    _themeMode = value;
    await _saveExpenses();
    notifyListeners();
  }

  Future<void> setDailyAlarm(TimeOfDay? value) async {
    _dailyAlarmTime = value;
    await _saveExpenses();
    notifyListeners();
  }

  Future<void> addCategory(String category) async {
    final clean = category.trim();
    if (clean.isEmpty || _budgetCategories.contains(clean)) return;
    _budgetCategories.add(clean);
    await _saveExpenses();
    notifyListeners();
  }

  Future<void> addExpense(
    String title,
    double amount,
    String category, {
    DateTime? date,
  }) async {
    final newExpense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: category,
      date: date ?? DateTime.now(),
    );
    _expenses.insert(0, newExpense);
    await _saveExpenses();
    try {
      await _firestoreService.addExpense(newExpense);
      _isCloudConnected = true;
    } catch (_) {
      _isCloudConnected = false;
    }
    notifyListeners();
    _refreshSmartTip();
  }

  void _refreshSmartTip() {
    if (todaySpent > dynamicDailyLimit) {
      _smartTip = 'Today limit crossed. Keep the next spending small.';
    } else if (financialHealthScore >= 80) {
      _smartTip = 'Good pace. You are protecting this month budget.';
    } else {
      _smartTip = 'Log every expense today to keep the dashboard accurate.';
    }
  }

  Future<void> updateExpense(
    String id,
    String title,
    double amount,
    String category,
  ) async {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      _expenses[index] = Expense(
        id: id,
        title: title,
        amount: amount,
        category: category,
        date: _expenses[index].date,
      );
      await _saveExpenses();
      try {
        await _firestoreService.updateExpense(_expenses[index]);
        _isCloudConnected = true;
      } catch (_) {
        _isCloudConnected = false;
      }
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((expense) => expense.id == id);
    await _saveExpenses();
    try {
      await _firestoreService.deleteExpense(id);
      _isCloudConnected = true;
    } catch (_) {
      _isCloudConnected = false;
    }
    notifyListeners();
    _refreshSmartTip();
  }

  Future<void> addDebt({
    required String person,
    required double amount,
    required String note,
    required bool theyOweMe,
    DateTime? reminderAt,
  }) async {
    final debt = DebtEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      person: person,
      amount: amount,
      note: note,
      theyOweMe: theyOweMe,
      date: DateTime.now(),
      reminderAt: reminderAt,
    );
    _debts.insert(0, debt);
    await _saveExpenses();
    try {
      await _firestoreService.setDebt(debt);
      _isCloudConnected = true;
    } catch (_) {
      _isCloudConnected = false;
    }
    notifyListeners();
  }

  Future<void> settleDebt(String id) async {
    final index = _debts.indexWhere((debt) => debt.id == id);
    if (index == -1) return;
    _debts[index] = _debts[index].copyWith(settled: true);
    await _saveExpenses();
    try {
      await _firestoreService.setDebt(_debts[index]);
      _isCloudConnected = true;
    } catch (_) {
      _isCloudConnected = false;
    }
    notifyListeners();
  }

  Future<void> deleteDebt(String id) async {
    _debts.removeWhere((debt) => debt.id == id);
    await _saveExpenses();
    notifyListeners();
  }

  @override
  void dispose() {
    _expenseSubscription?.cancel();
    _debtSubscription?.cancel();
    super.dispose();
  }
}
