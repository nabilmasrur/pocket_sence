class DebtEntry {
  final String id;
  final String person;
  final double amount;
  final String note;
  final bool theyOweMe;
  final DateTime date;
  final DateTime? reminderAt;
  final bool settled;

  const DebtEntry({
    required this.id,
    required this.person,
    required this.amount,
    required this.note,
    required this.theyOweMe,
    required this.date,
    this.reminderAt,
    this.settled = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'person': person,
    'amount': amount,
    'note': note,
    'theyOweMe': theyOweMe,
    'date': date.toIso8601String(),
    'reminderAt': reminderAt?.toIso8601String(),
    'settled': settled,
  };

  factory DebtEntry.fromJson(Map<String, dynamic> json) => DebtEntry(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    person: json['person'] ?? 'Friend',
    amount: double.tryParse(json['amount'].toString()) ?? 0,
    note: json['note'] ?? '',
    theyOweMe: json['theyOweMe'] ?? true,
    date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    reminderAt: json['reminderAt'] == null
        ? null
        : DateTime.tryParse(json['reminderAt'].toString()),
    settled: json['settled'] ?? false,
  );

  DebtEntry copyWith({bool? settled, DateTime? reminderAt}) {
    return DebtEntry(
      id: id,
      person: person,
      amount: amount,
      note: note,
      theyOweMe: theyOweMe,
      date: date,
      reminderAt: reminderAt ?? this.reminderAt,
      settled: settled ?? this.settled,
    );
  }
}
