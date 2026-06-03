class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? voucherUrl;
  final String? voucherPublicId;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.voucherUrl,
    this.voucherPublicId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'voucherUrl': voucherUrl,
    'voucherPublicId': voucherPublicId,
  };

  factory Expense.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'];
    DateTime parsedDate = DateTime.now();

    if (rawDate is String) {
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
      voucherUrl: json['voucherUrl']?.toString(),
      voucherPublicId: json['voucherPublicId']?.toString(),
    );
  }

  Expense copyWith({
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? voucherUrl,
    String? voucherPublicId,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      voucherUrl: voucherUrl ?? this.voucherUrl,
      voucherPublicId: voucherPublicId ?? this.voucherPublicId,
    );
  }
}
