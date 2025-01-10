class TransactionModel {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final String description;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
  });

  // Konversi ke Map (untuk Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  // Konversi dari Map (dari Firestore)
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      userId: map['userId'],
      category: map['category'],
      amount: map['amount'],
      description: map['description'],
      date: DateTime.parse(map['date']),
    );
  }
}
