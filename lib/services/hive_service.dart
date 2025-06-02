import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveManager {
  static const String transactionsBoxName = 'transactions';
  static const String categoriesBoxName = 'categories';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }

    // Open boxes
    await Hive.openBox<TransactionModel>(transactionsBoxName);
    await Hive.openBox<CategoryModel>(categoriesBoxName);
  }

  // --- Transaction Methods ---

  static Box<TransactionModel> get _transactionBox => Hive.box<TransactionModel>(transactionsBoxName);

  static Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  static List<TransactionModel> getAllTransactions() {
    return _transactionBox.values.toList();
  }

  static Future<void> deleteTransaction(String id) async {
    await _transactionBox.delete(id);
  }

  static Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  // --- Category Methods ---

  static Box<CategoryModel> get _categoryBox => Hive.box<CategoryModel>(categoriesBoxName);

  static Future<void> addCategory(CategoryModel category) async {
    await _categoryBox.put(category.id, category);
  }

  static List<CategoryModel> getAllCategories() {
    return _categoryBox.values.toList();
  }

  static Future<void> deleteCategory(String id) async {
    await _categoryBox.delete(id);
  }

  static Future<void> updateCategory(CategoryModel category) async {
    await _categoryBox.put(category.id, category);
  }
}
