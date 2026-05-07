import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _gold = Color(0xFFFFD21F);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            _profileCard(context, provider),
            const SizedBox(height: 14),
            _budgetCard(context, provider),
            const SizedBox(height: 14),
            _calendarCard(context, provider),
            const SizedBox(height: 14),
            _alarmCard(context, provider),
            const SizedBox(height: 14),
            _themeCard(provider),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(BuildContext context, ExpenseProvider provider) {
    return _glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: _gold,
                child: Text(
                  'N',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Abu Nabil Md. Masrur',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'BAUST | ID: 0802410405101077',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showPasswordSheet(context),
                  icon: const Icon(Icons.lock_reset_rounded),
                  label: const Text('Change Password'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _budgetCard(BuildContext context, ExpenseProvider provider) {
    return _glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Budget Setup',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          _budgetRow(context, 'Daily', provider.dailyBudget, (value) {
            provider.setBudgets(daily: value);
          }),
          _budgetRow(context, 'Weekly', provider.weeklyBudget, (value) {
            provider.setBudgets(weekly: value);
          }),
          _budgetRow(context, 'Monthly', provider.monthlyBudget, (value) {
            provider.setBudgets(monthly: value);
          }),
          _budgetRow(context, 'Yearly', provider.yearlyBudget, (value) {
            provider.setBudgets(yearly: value);
          }),
        ],
      ),
    );
  }

  Widget _budgetRow(
    BuildContext context,
    String label,
    double value,
    ValueChanged<double> onSave,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        'BDT ${value.toStringAsFixed(0)}',
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: const Icon(Icons.edit_rounded),
      onTap: () => _showNumberSheet(context, '$label budget', value, onSave),
    );
  }

  Widget _calendarCard(BuildContext context, ExpenseProvider provider) {
    return _glass(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.calendar_month_rounded, color: _gold),
        title: const Text(
          'Previous Records',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        subtitle: const Text(
          'Open calendar and view short daily history',
          style: TextStyle(color: Colors.white54),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => _showCalendarHistory(context, provider),
      ),
    );
  }

  Widget _alarmCard(BuildContext context, ExpenseProvider provider) {
    final alarm = provider.dailyAlarmTime;
    return _glass(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.alarm_rounded, color: _gold),
        title: const Text(
          'Daily Alarm',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          alarm == null ? 'Not set' : alarm.format(context),
          style: const TextStyle(color: Colors.white54),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: alarm ?? TimeOfDay.now(),
          );
          await provider.setDailyAlarm(picked);
        },
      ),
    );
  }

  Widget _themeCard(ExpenseProvider provider) {
    return _glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theme',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'default', label: Text('Default')),
              ButtonSegment(value: 'dark', label: Text('Dark')),
              ButtonSegment(value: 'light', label: Text('Light')),
            ],
            selected: {provider.themeMode},
            onSelectionChanged: (value) => provider.setThemeMode(value.first),
          ),
        ],
      ),
    );
  }

  void _showNumberSheet(
    BuildContext context,
    String title,
    double value,
    ValueChanged<double> onSave,
  ) {
    final controller = TextEditingController(text: value.toStringAsFixed(0));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF08110E),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Amount'),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final parsed = double.tryParse(controller.text.trim());
                  if (parsed != null) onSave(parsed);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCalendarHistory(
    BuildContext context,
    ExpenseProvider provider,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null || !context.mounted) return;
    final records = provider.expensesOn(picked);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF08110E),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMM d, yyyy').format(picked),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: BDT ${provider.spentOn(picked).toStringAsFixed(0)}',
              style: const TextStyle(color: _gold),
            ),
            const SizedBox(height: 14),
            if (records.isEmpty)
              const Text(
                'No records found',
                style: TextStyle(color: Colors.white54),
              )
            else
              ...records.map(
                (expense) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    expense.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    expense.category,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: Text(
                    'BDT ${expense.amount.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPasswordSheet(BuildContext context) {
    final controller = TextEditingController();
    final auth = AuthService();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF08110E),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'New password'),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final ok = await auth.changePassword(controller.text);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'Password changed'
                            : 'Login recently and try again.',
                      ),
                    ),
                  );
                },
                child: const Text('Update Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glass({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }
}
