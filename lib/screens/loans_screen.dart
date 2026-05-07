import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';

class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});

  static const _gold = Color(0xFFFFD21F);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final active = provider.debts.where((debt) => !debt.settled).toList();
    final settled = provider.debts.where((debt) => debt.settled).toList();
    final receivable = active
        .where((debt) => debt.theyOweMe)
        .fold<double>(0, (sum, debt) => sum + debt.amount);
    final payable = active
        .where((debt) => !debt.theyOweMe)
        .fold<double>(0, (sum, debt) => sum + debt.amount);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Loans & Debts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                IconButton.filled(
                  onPressed: () => _showAddDebtSheet(context),
                  style: IconButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _summary(
                    'To collect',
                    'BDT ${receivable.toStringAsFixed(0)}',
                    Icons.south_west_rounded,
                    const Color(0xFF35E6A8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summary(
                    'To pay',
                    'BDT ${payable.toStringAsFixed(0)}',
                    Icons.north_east_rounded,
                    const Color(0xFFFF8A3D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Active Records',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            if (active.isEmpty)
              _empty('No active loan/debt records')
            else
              ...active.map((debt) => _debtTile(context, provider, debt)),
            if (settled.isNotEmpty) ...[
              const SizedBox(height: 22),
              const Text(
                'Settled',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              ...settled.map((debt) => _debtTile(context, provider, debt)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summary(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.white54)),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white54)),
    );
  }

  Widget _debtTile(BuildContext context, ExpenseProvider provider, debt) {
    final color = debt.theyOweMe
        ? const Color(0xFF35E6A8)
        : const Color(0xFFFF8A3D);
    return Dismissible(
      key: ValueKey(debt.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.redAccent),
      ),
      onDismissed: (_) => provider.deleteDebt(debt.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: debt.settled ? 0.035 : 0.06),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.20),
              child: Icon(
                debt.theyOweMe
                    ? Icons.call_received_rounded
                    : Icons.call_made_rounded,
                color: color,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    debt.person,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    debt.note,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  if (debt.reminderAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Reminder: ${DateFormat('MMM d, h:mm a').format(debt.reminderAt!)}',
                      style: const TextStyle(color: _gold, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'BDT ${debt.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (!debt.settled)
                  TextButton(
                    onPressed: () => provider.settleDebt(debt.id),
                    child: const Text('Settle'),
                  )
                else
                  const Text('Done', style: TextStyle(color: Colors.white38)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDebtSheet(BuildContext context) {
    final provider = context.read<ExpenseProvider>();
    final person = TextEditingController();
    final amount = TextEditingController();
    final note = TextEditingController();
    var theyOweMe = true;
    DateTime? reminder;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF08110E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
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
                  'Add Loan / Debt',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                _field(person, 'Person name', Icons.person_rounded),
                const SizedBox(height: 10),
                _field(
                  amount,
                  'Amount',
                  Icons.payments_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                _field(note, 'Note', Icons.notes_rounded),
                SwitchListTile(
                  value: theyOweMe,
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: _gold,
                  title: const Text(
                    'They owe me',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    theyOweMe
                        ? 'You need to collect this'
                        : 'You need to pay this',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  onChanged: (value) => setSheetState(() => theyOweMe = value),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.alarm_rounded, color: _gold),
                  title: Text(
                    reminder == null
                        ? 'Set reminder alarm'
                        : DateFormat('MMM d, yyyy - h:mm a').format(reminder!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2035),
                    );
                    if (date == null || !context.mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time == null) return;
                    setSheetState(() {
                      reminder = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final parsed = double.tryParse(amount.text.trim());
                      if (person.text.trim().isEmpty || parsed == null) return;
                      await provider.addDebt(
                        person: person.text.trim(),
                        amount: parsed,
                        note: note.text.trim(),
                        theyOweMe: theyOweMe,
                        reminderAt: reminder,
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text(
                      'Save Record',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: _gold),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
