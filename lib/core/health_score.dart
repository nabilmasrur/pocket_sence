import '../models/expense.dart';
import 'budget_engine.dart';

class HealthScore {
  static int calculate({
    required List<Expense> expenses,
    required double monthlyBudget,
  }) {
    final todayLimit = BudgetEngine.dynamicDailyLimit(
      expenses: expenses,
      monthlyBudget: monthlyBudget,
    );
    final spentToday = BudgetEngine.todaySpent(expenses);
    final monthSpent = expenses
        .where((expense) {
          final now = DateTime.now();
          return expense.date.year == now.year &&
              expense.date.month == now.month;
        })
        .fold<double>(0, (sum, expense) => sum + expense.amount);

    final dailyScore = todayLimit <= 0
        ? 40
        : (100 - ((spentToday / todayLimit) * 42)).clamp(0, 100);
    final monthlyScore = (100 - ((monthSpent / monthlyBudget) * 48)).clamp(
      0,
      100,
    );
    final consistencyBonus = expenses.length >= 5 ? 8 : expenses.length * 1.6;
    return ((dailyScore * 0.5) + (monthlyScore * 0.42) + consistencyBonus)
        .clamp(0, 100)
        .round();
  }
}
