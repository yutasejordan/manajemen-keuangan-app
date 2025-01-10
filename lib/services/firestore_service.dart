import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> addTransaction(TransactionModel transaction) async {
    await _firestore
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toMap());
  }

  static Future<void> updateTransaction(TransactionModel transaction) async {
    await _firestore
        .collection('transactions')
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  static Future<void> deleteTransaction(String id) async {
    await _firestore.collection('transactions').doc(id).delete();
  }

  static Stream<List<TransactionModel>> getTransactions(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data()))
          .toList();
    });
  }
}
