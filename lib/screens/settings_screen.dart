import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/app_colors.dart';
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
            Text(
              'Settings',
              style: TextStyle(
                color: AppColors.text(context),
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
            _themeCard(context, provider),
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
              FutureBuilder<AppUserProfile>(
                future: AuthService().currentProfile(),
                builder: (context, snapshot) {
                  final name = snapshot.data?.name.trim().isNotEmpty == true
                      ? snapshot.data!.name
                      : 'Pocket Sense User';
                  return CircleAvatar(
                    radius: 26,
                    backgroundColor: _gold,
                    backgroundImage: snapshot.data?.photoUrl == null
                        ? null
                        : NetworkImage(snapshot.data!.photoUrl!),
                    child: snapshot.data?.photoUrl == null
                        ? Text(
                            name.characters.first.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  );
                },
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FutureBuilder<AppUserProfile>(
                  future: AuthService().currentProfile(),
                  builder: (context, snapshot) {
                    final name = snapshot.data?.name.trim().isNotEmpty == true
                        ? snapshot.data!.name
                        : 'Pocket Sense User';
                    final contact =
                        snapshot.data?.phoneNumber.trim().isNotEmpty == true
                        ? snapshot.data!.phoneNumber
                        : snapshot.data?.email ?? '';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: AppColors.text(context),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (contact.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            contact,
                            style: TextStyle(
                              color: AppColors.muted(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
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
          Text(
            'Budget Setup',
            style: TextStyle(
              color: AppColors.text(context),
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
      title: Text(label, style: TextStyle(color: AppColors.text(context))),
      subtitle: Text(
        'BDT ${value.toStringAsFixed(0)}',
        style: TextStyle(color: AppColors.muted(context)),
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
        title: Text(
          'Previous Records',
          style: TextStyle(
            color: AppColors.text(context),
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          'Open calendar and view short daily history',
          style: TextStyle(color: AppColors.muted(context)),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => _showCalendarHistory(context, provider),
      ),
    );
  }

  Widget _alarmCard(BuildContext context, ExpenseProvider provider) {
    final alarm = provider.dailyNotificationTime;
    return _glass(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.notifications_active_rounded, color: _gold),
        title: Text(
          'Daily Notification Time',
          style: TextStyle(
            color: AppColors.text(context),
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          alarm == null ? 'Not set' : alarm.format(context),
          style: TextStyle(color: AppColors.muted(context)),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: alarm ?? TimeOfDay.now(),
          );
          await provider.setDailyNotificationTime(picked);
        },
      ),
    );
  }

  Widget _themeCard(BuildContext context, ExpenseProvider provider) {
    return _glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: TextStyle(
              color: AppColors.text(context),
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
  ) {
    DateTime focusedDay = DateTime.now();
    DateTime? selectedDay = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF08110E),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final records = provider.expensesOn(selectedDay!);
            return FractionallySizedBox(
              heightFactor: 0.85,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TableCalendar(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2035),
                    focusedDay: focusedDay,
                    selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        selectedDay = selected;
                        focusedDay = focused;
                      });
                    },
                    eventLoader: (day) {
                      return provider.expensesOn(day);
                    },
                    calendarStyle: const CalendarStyle(
                      markerDecoration: BoxDecoration(
                        color: _gold,
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: TextStyle(color: Colors.white),
                      weekendTextStyle: TextStyle(color: Colors.white70),
                      outsideTextStyle: TextStyle(color: Colors.white38),
                      selectedDecoration: BoxDecoration(
                        color: _gold,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      todayDecoration: BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                      rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.white),
                      weekendStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const Divider(color: Colors.white12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM d, yyyy').format(selectedDay!),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total: BDT ${provider.spentOn(selectedDay!).toStringAsFixed(0)}',
                          style: const TextStyle(color: _gold, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: records.isEmpty
                        ? const Center(
                            child: Text(
                              'No records found',
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: records.length,
                            itemBuilder: (context, index) {
                              final expense = records[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    expense.title,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    expense.category,
                                    style: const TextStyle(color: Colors.white54),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (expense.voucherUrl != null)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 8.0),
                                          child: Icon(Icons.image_rounded, color: _gold, size: 20),
                                        ),
                                      Text(
                                        'BDT ${expense.amount.toStringAsFixed(0)}',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  onTap: expense.voucherUrl == null
                                      ? null
                                      : () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              backgroundColor: Colors.transparent,
                                              child: Stack(
                                                alignment: Alignment.topRight,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(16),
                                                    child: Image.network(expense.voucherUrl!),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                                                    onPressed: () => Navigator.pop(context),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                ),
                              );
                            },
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
