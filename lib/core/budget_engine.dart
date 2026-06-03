import '../models/expense.dart';

class BudgetEngine {
  static double dynamicDailyLimit({
    required List<Expense> expenses,
    required double monthlyBudget,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    final remainingDays = (daysInMonth - today.day + 1).clamp(1, daysInMonth);
    final spentThisMonthBeforeToday = expenses
        .where(
          (expense) =>
              expense.date.year == today.year &&
              expense.date.month == today.month &&
              expense.date.day != today.day,
        )
        .fold<double>(0, (sum, expense) => sum + expense.amount);
    final remainingBudget = (monthlyBudget - spentThisMonthBeforeToday).clamp(
      0,
      monthlyBudget,
    );
    return remainingBudget / remainingDays;
  }

  static double todaySpent(List<Expense> expenses, {DateTime? now}) {
    final today = now ?? DateTime.now();
    return expenses
        .where(
          (expense) =>
              expense.date.year == today.year &&
              expense.date.month == today.month &&
              expense.date.day == today.day,
        )
        .fold<double>(0, (sum, expense) => sum + expense.amount);
  }
}
