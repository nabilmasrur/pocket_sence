import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int touchedPie = -1;
  double lineZoom = 1;

  static const _gold = Color(0xFFFFD21F);
  static const _panel = Color(0xFF08110E);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final categoryTotals = _categoryTotals(provider.expenses);
    final maxTotal = categoryTotals.values.fold<double>(1, max);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 112),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Smart Statistics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _predictionCard(provider),
            const SizedBox(height: 18),
            _lineCard(provider.expenses),
            const SizedBox(height: 18),
            _pieCard(categoryTotals),
            const SizedBox(height: 22),
            const Text(
              'Top Categories',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (categoryTotals.isEmpty)
              Text(
                'No spending data yet',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              ...categoryTotals.entries.map((entry) {
                return _buildCategoryItem(
                  icon: _iconFor(entry.key),
                  title: entry.key,
                  amount: entry.value,
                  progress: (entry.value / maxTotal).clamp(0.05, 1),
                  color: _colorFor(entry.key),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _predictionCard(ExpenseProvider provider) {
    return _glass(
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: _gold,
            child: Icon(Icons.insights_rounded, color: Colors.black),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Predicted Monthly Bill',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.48),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'BDT ${provider.predictedMonthlyBill.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${provider.financialHealthScore}/100',
            style: const TextStyle(color: _gold, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _lineCard(List<Expense> expenses) {
    final spots = _dailySpots(expenses);
    final maxY = spots.map((spot) => spot.y).fold<double>(100, max);

    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() => lineZoom = (lineZoom * details.scale).clamp(0.75, 2.5));
      },
      child: _glass(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Zoomable Spending Curve',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${lineZoom.toStringAsFixed(1)}x',
                  style: const TextStyle(
                    color: _gold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 190,
              child: LineChart(
                LineChartData(
                  minX: max(1, 31 - (30 / lineZoom)),
                  maxX: 31,
                  minY: 0,
                  maxY: maxY * 1.25,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: Colors.white12, strokeWidth: 1),
                  ),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchCallback: (_, response) {
                      if (response?.lineBarSpots?.isNotEmpty == true) {
                        HapticFeedback.selectionClick();
                      }
                    },
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 4,
                      color: _gold,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _gold.withValues(alpha: 0.28),
                            _gold.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pieCard(Map<String, double> categoryTotals) {
    final entries = categoryTotals.entries.toList();
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.value);

    return _glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tappable Category Pie',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      'Add expenses to unlock chart',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.48),
                      ),
                    ),
                  )
                : PieChart(
                    PieChartData(
                      centerSpaceRadius: 52,
                      sectionsSpace: 4,
                      pieTouchData: PieTouchData(
                        touchCallback: (_, response) {
                          final index =
                              response?.touchedSection?.touchedSectionIndex ??
                              -1;
                          if (index != touchedPie) {
                            HapticFeedback.selectionClick();
                          }
                          setState(() => touchedPie = index);
                        },
                      ),
                      sections: List.generate(entries.length, (index) {
                        final entry = entries[index];
                        final active = index == touchedPie;
                        final percent = total == 0
                            ? 0
                            : (entry.value / total) * 100;
                        return PieChartSectionData(
                          value: entry.value,
                          title: active ? '${percent.toStringAsFixed(0)}%' : '',
                          radius: active ? 78 : 64,
                          color: _colorFor(entry.key),
                          titleStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                        );
                      }),
                    ),
                  ),
          ),
          if (touchedPie >= 0 && touchedPie < entries.length)
            Center(
              child: Text(
                '${entries[touchedPie].key}: BDT ${entries[touchedPie].value.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: _gold,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Map<String, double> _categoryTotals(List<Expense> expenses) {
    final totals = <String, double>{};
    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return Map.fromEntries(
      totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  List<FlSpot> _dailySpots(List<Expense> expenses) {
    final now = DateTime.now();
    final totals = <int, double>{};
    for (final expense in expenses) {
      if (expense.date.year == now.year && expense.date.month == now.month) {
        totals[expense.date.day] =
            (totals[expense.date.day] ?? 0) + expense.amount;
      }
    }
    return List.generate(31, (index) {
      final day = index + 1;
      return FlSpot(day.toDouble(), totals[day] ?? 0);
    });
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String title,
    required double amount,
    required double progress,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'BDT ${amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glass({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panel.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: 0.06),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }

  IconData _iconFor(String category) {
    switch (category) {
      case 'Food & Drink':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_bus_filled_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      default:
        return Icons.savings_rounded;
    }
  }

  Color _colorFor(String category) {
    switch (category) {
      case 'Food & Drink':
        return const Color(0xFFFF8A3D);
      case 'Transport':
        return const Color(0xFF54A3FF);
      case 'Shopping':
        return const Color(0xFF35E6A8);
      case 'Bills':
        return const Color(0xFFB777FF);
      default:
        return const Color(0xFF9CA3AF);
    }
  }
}
