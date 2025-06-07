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
