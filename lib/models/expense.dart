import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
  };

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'amount': amount,
    'category': category,
    'date': Timestamp.fromDate(date),
  };

  factory Expense.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'];
    DateTime parsedDate = DateTime.now();

    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    }

    return Expense(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Unknown',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      category: json['category'] ?? 'Others',
      date: parsedDate,
    );
  }
}
