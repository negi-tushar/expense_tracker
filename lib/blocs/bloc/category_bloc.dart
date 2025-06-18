// lib/blocs/categories/category_bloc.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/services/hive_service.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryInitial()) {
    // MODIFIED: We now have one handler for initialization.
    on<InitializeCategories>(_onInitializeCategories);

    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  // REWRITTEN: This handler now does everything.
  Future<void> _onInitializeCategories(InitializeCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading()); // 1. Emit Loading first
    try {
      // 2. Check if data is empty
      final categories = HiveManager.getAllCategories();
      if (categories.isEmpty) {
        // 3. If empty, seed the database
        final List<CategoryModel> defaultCategories = [
          CategoryModel(name: 'Food', iconCodePoint: Icons.fastfood.codePoint, isIncome: false),
          CategoryModel(name: 'Transport', iconCodePoint: Icons.directions_car.codePoint, isIncome: false),
          CategoryModel(name: 'Shopping', iconCodePoint: Icons.shopping_bag.codePoint, isIncome: false),
          CategoryModel(name: 'Bills', iconCodePoint: Icons.receipt_long.codePoint, isIncome: false),
          CategoryModel(name: 'Entertainment', iconCodePoint: Icons.movie.codePoint, isIncome: false),
          CategoryModel(name: 'Salary', iconCodePoint: Icons.attach_money.codePoint, isIncome: true),
          CategoryModel(name: 'Bonus', iconCodePoint: Icons.card_giftcard.codePoint, isIncome: true),
          CategoryModel(name: 'Investments', iconCodePoint: Icons.trending_up.codePoint, isIncome: true),
          CategoryModel(name: 'Groceries', iconCodePoint: Icons.local_grocery_store.codePoint, isIncome: false),
          CategoryModel(name: 'Dining Out', iconCodePoint: Icons.restaurant.codePoint, isIncome: false),
          CategoryModel(name: 'Utilities', iconCodePoint: Icons.lightbulb_outline.codePoint, isIncome: false),
          CategoryModel(name: 'Rent/Mortgage', iconCodePoint: Icons.home_work.codePoint, isIncome: false),
          CategoryModel(name: 'Insurance', iconCodePoint: Icons.security.codePoint, isIncome: false),
          CategoryModel(name: 'Pet Care', iconCodePoint: Icons.pets.codePoint, isIncome: false),
          CategoryModel(name: 'Kids/Family', iconCodePoint: Icons.family_restroom.codePoint, isIncome: false),
          CategoryModel(name: 'Subscriptions', iconCodePoint: Icons.subscriptions.codePoint, isIncome: false),
          CategoryModel(name: 'Debt Payments', iconCodePoint: Icons.credit_card_off.codePoint, isIncome: false),
          CategoryModel(name: 'Gifts Given', iconCodePoint: Icons.redeem.codePoint, isIncome: false),
          CategoryModel(name: 'Repairs & Maintenance', iconCodePoint: Icons.build.codePoint, isIncome: false),
          CategoryModel(name: 'Clothing', iconCodePoint: Icons.checkroom.codePoint, isIncome: false),
          CategoryModel(name: 'Beauty', iconCodePoint: Icons.face_retouching_natural.codePoint, isIncome: false),
          CategoryModel(name: 'Hobbies', iconCodePoint: Icons.palette.codePoint, isIncome: false),
          CategoryModel(name: 'Sport', iconCodePoint: Icons.sports_basketball.codePoint, isIncome: false),
          CategoryModel(name: 'Commute', iconCodePoint: Icons.train.codePoint, isIncome: false),
          CategoryModel(name: 'Parking & Tolls', iconCodePoint: Icons.local_parking.codePoint, isIncome: false),
          CategoryModel(name: 'Car Maintenance', iconCodePoint: Icons.car_repair.codePoint, isIncome: false),
          CategoryModel(name: 'Taxes', iconCodePoint: Icons.receipt.codePoint, isIncome: false),
          CategoryModel(name: 'Charity', iconCodePoint: Icons.favorite_border.codePoint, isIncome: false),
          CategoryModel(name: 'Electronics', iconCodePoint: Icons.devices.codePoint, isIncome: false),
          CategoryModel(name: 'Home Furnishings', iconCodePoint: Icons.chair.codePoint, isIncome: false),
          CategoryModel(name: 'Business Expenses', iconCodePoint: Icons.business_center.codePoint, isIncome: false),
          CategoryModel(name: 'Legal Fees', iconCodePoint: Icons.gavel.codePoint, isIncome: false),
          CategoryModel(name: 'Bank Fees', iconCodePoint: Icons.account_balance.codePoint, isIncome: false),
        ];
        for (final category in defaultCategories) {
          await HiveManager.addCategory(category);
        }
      }
      // 4. After checking/seeding, load and emit the final state.
      await _loadAndEmitCategories(emit);
    } catch (e) {
      emit(CategoryError("Failed to initialize categories: ${e.toString()}"));
    }
  }

  // MODIFIED: The other handlers now use the helper method.
  Future<void> _onAddCategory(AddCategory event, Emitter<CategoryState> emit) async {
    try {
      await HiveManager.addCategory(event.category);
      await _loadAndEmitCategories(emit);
    } catch (e) {
      emit(CategoryError("Failed to add category: ${e.toString()}"));
    }
  }

  Future<void> _onUpdateCategory(UpdateCategory event, Emitter<CategoryState> emit) async {
    try {
      await HiveManager.updateCategory(event.category);
      await _loadAndEmitCategories(emit);
    } catch (e) {
      emit(CategoryError("Failed to update category: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteCategory(DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      await HiveManager.deleteCategory(event.categoryKey);
      await _loadAndEmitCategories(emit);
    } catch (e) {
      emit(CategoryError("Failed to delete category: ${e.toString()}"));
    }
  }

  // ADDED: A private helper to avoid repeating code.
  Future<void> _loadAndEmitCategories(Emitter<CategoryState> emit) async {
    final allCategories = HiveManager.getAllCategories();
    final incomeCategories = allCategories.where((cat) => cat.isIncome).toList();
    final expenseCategories = allCategories.where((cat) => !cat.isIncome).toList();
    emit(CategoryLoaded(
      incomeCategories: incomeCategories,
      expenseCategories: expenseCategories,
    ));
  }
}
