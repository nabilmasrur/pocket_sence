import '../models/expense.dart';

class PredictionEngine {
  static double predictedMonthlyBill(List<Expense> expenses, {DateTime? now}) {
    final anchor = now ?? DateTime.now();
    final monthTotals = <String, double>{};

    for (final expense in expenses) {
      final monthStart = DateTime(expense.date.year, expense.date.month);
      if (monthStart.isBefore(DateTime(anchor.year, anchor.month - 3)) ||
          (expense.date.year == anchor.year &&
              expense.date.month == anchor.month)) {
        continue;
      }
      final key = '${expense.date.year}-${expense.date.month}';
      monthTotals[key] = (monthTotals[key] ?? 0) + expense.amount;
    }

    if (monthTotals.isEmpty) {
      final spent = expenses.fold<double>(
        0,
        (sum, expense) => sum + expense.amount,
      );
      return spent == 0 ? 0 : spent * 1.12;
    }

    final average =
        monthTotals.values.fold<double>(0, (sum, value) => sum + value) /
        monthTotals.length;
    return average * 1.06;
  }
}
