// lib/blocs/categories/category_state.dart

import 'package:equatable/equatable.dart';
import 'package:expense_tracker/models/category_model.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

/// The initial state before any action has been taken
class CategoryInitial extends CategoryState {}

/// State while categories are being loaded from the database
class CategoryLoading extends CategoryState {}

/// State when categories have been successfully loaded
class CategoryLoaded extends CategoryState {
  final List<CategoryModel> incomeCategories;
  final List<CategoryModel> expenseCategories;

  const CategoryLoaded({
    this.incomeCategories = const [],
    this.expenseCategories = const [],
  });

  @override
  List<Object> get props => [incomeCategories, expenseCategories];
}

/// State when an error occurs during category operations
class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object> get props => [message];
}
