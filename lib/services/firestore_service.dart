import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/debt_entry.dart';
import '../models/expense.dart';

class FirestoreService {
  FirebaseFirestore? get _db {
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint("Firestore unavailable: $e");
      return null;
    }
  }

  FirebaseAuth? get _auth {
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint("Firebase Auth unavailable: $e");
      return null;
    }
  }

  // Get current user ID
  String? get _userId => _auth?.currentUser?.uid;

  // Stream of Expenses for current user
  Stream<List<Expense>> getExpenses() {
    final db = _db;
    final userId = _userId;
    if (db == null || userId == null) return Stream.value([]);

    return db
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Expense.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  // Add Expense
  Future<void> addExpense(Expense expense) {
    final db = _db;
    final userId = _userId;
    if (db == null || userId == null) return Future.value();

    return db
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expense.id)
        .set(expense.toFirestore());
  }

  // Update Expense
  Future<void> updateExpense(Expense expense) {
    final db = _db;
    final userId = _userId;
    if (db == null || userId == null) return Future.value();

    return db
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expense.id)
        .set(expense.toFirestore(), SetOptions(merge: true));
  }

  // Delete Expense
  Future<void> deleteExpense(String id) {
    final db = _db;
    final userId = _userId;
    if (db == null || userId == null) return Future.value();

    return db
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(id)
        .delete();
  }

  Stream<List<DebtEntry>> getDebts() {
    final db = _db;
    final userId = _userId;
    if (db == null || userId == null) return Stream.value([]);

    return db
        .collection('users')
        .doc(userId)
        .collection('debts')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DebtEntry.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  Future<void> setDebt(DebtEntry debt) {
    final db = _db;
    final userId = _userId;
    if (db == null || userId == null) return Future.value();

    return db
        .collection('users')
        .doc(userId)
        .collection('debts')
        .doc(debt.id)
        .set(debt.toJson(), SetOptions(merge: true));
  }
}
