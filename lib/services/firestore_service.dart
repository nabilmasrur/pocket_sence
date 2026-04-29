import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Stream of Expenses for current user
  Stream<List<Expense>> getExpenses() {
    if (_userId == null) return Stream.value([]);
    
    return _db
        .collection('users')
        .doc(_userId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Add Expense
  Future<void> addExpense(Expense expense) {
    if (_userId == null) return Future.value();
    
    return _db
        .collection('users')
        .doc(_userId)
        .collection('expenses')
        .add(expense.toJson());
  }

  // Update Expense
  Future<void> updateExpense(Expense expense) {
    if (_userId == null) return Future.value();

    return _db
        .collection('users')
        .doc(_userId)
        .collection('expenses')
        .doc(expense.id)
        .update(expense.toJson());
  }

  // Delete Expense
  Future<void> deleteExpense(String id) {
    if (_userId == null) return Future.value();

    return _db
        .collection('users')
        .doc(_userId)
        .collection('expenses')
        .doc(id)
        .delete();
  }
}
