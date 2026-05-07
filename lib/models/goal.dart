class Goal {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;

  const Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
  });

  double get progress {
    if (targetAmount <= 0) return 0;
    return (savedAmount / targetAmount).clamp(0, 1);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'savedAmount': savedAmount,
  };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    name: json['name'] ?? 'Emergency Fund',
    targetAmount: double.tryParse(json['targetAmount'].toString()) ?? 50000,
    savedAmount: double.tryParse(json['savedAmount'].toString()) ?? 0,
  );
}
