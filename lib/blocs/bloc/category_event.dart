// lib/blocs/categories/category_event.dart

import 'package:equatable/equatable.dart';
import 'package:expense_tracker/models/category_model.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

// MODIFIED: This is now the single event for all loading/initialization.
/// Event to initialize categories: seeds default data if needed, then loads all.
class InitializeCategories extends CategoryEvent {}

// Add, Update, and Delete events remain the same...
class AddCategory extends CategoryEvent {
  final CategoryModel category;
  const AddCategory(this.category);
  @override
  List<Object> get props => [category];
}

class UpdateCategory extends CategoryEvent {
  final CategoryModel category;
  const UpdateCategory(this.category);
  @override
  List<Object> get props => [category];
}

class DeleteCategory extends CategoryEvent {
  final int categoryKey;

  const DeleteCategory(this.categoryKey);

  @override
  List<Object> get props => [categoryKey];
}
