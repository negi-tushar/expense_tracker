import 'package:expense_tracker/blocs/bloc/category_bloc.dart';
import 'package:expense_tracker/blocs/bloc/category_event.dart';
import 'package:expense_tracker/blocs/bloc/category_state.dart';
import 'package:expense_tracker/blocs/transactions/transaction_bloc.dart';
import 'package:expense_tracker/blocs/transactions/transaction_event.dart';
import 'package:expense_tracker/blocs/transactions/transaction_state.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/screens/add_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CategorySelectionScreen extends StatefulWidget {
  final TransactionModel? existingTransaction;

  const CategorySelectionScreen({super.key, this.existingTransaction});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> with SingleTickerProviderStateMixin {
  bool isIncome = false;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  late AnimationController _animationController;

  CategoryModel? _selectedCategory;
  bool _isInitialLoad = true;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
    super.initState();
    if (widget.existingTransaction != null) {
      final txn = widget.existingTransaction!;
      isIncome = txn.isIncome;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionLoaded) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Select Category', style: GoogleFonts.poppins()),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: "Add Category",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCategoryScreen()));
              },
            ),
          ],
        ),
        body: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading || state is CategoryInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CategoryError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is CategoryLoaded) {
              if (_isInitialLoad && widget.existingTransaction != null) {
                final categoriesForTxn =
                    widget.existingTransaction!.isIncome ? state.incomeCategories : state.expenseCategories;
                try {
                  _selectedCategory = categoriesForTxn.firstWhere(
                    (cat) => cat.name == widget.existingTransaction!.categoryName,
                  );
                } catch (e) {
                  _selectedCategory = null;
                }
                _isInitialLoad = false;
              }

              final categories = isIncome ? state.incomeCategories : state.expenseCategories;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildToggleSwitch(),
                  Expanded(
                    child: categories.isEmpty
                        ? Center(
                            child: Text(
                              "No ${isIncome ? 'income' : 'expense'} categories found.\nAdd one using the '+' button!",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                          )
                        // MODIFIED: Calling the new GridView method
                        : _buildCategoryGrid(categories),
                  ),
                ],
              );
            }

            return const Center(child: Text("Something went wrong."));
          },
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Center(
      child: ToggleButtons(
        isSelected: [!isIncome, isIncome],
        borderRadius: BorderRadius.circular(10),
        fillColor: Colors.black,
        selectedColor: Colors.white,
        color: Colors.black87,
        constraints: const BoxConstraints(minHeight: 40, minWidth: 100),
        onPressed: (index) {
          setState(() {
            isIncome = index == 1;
            _selectedCategory = null;
          });
          _animationController.reset();
          _animationController.forward();
        },
        children: [
          Text("Expense", style: GoogleFonts.poppins()),
          Text("Income", style: GoogleFonts.poppins()),
        ],
      ),
    );
  }

  // REPLACED: _buildCategoryWrap is now _buildCategoryGrid
  Widget _buildCategoryGrid(List<CategoryModel> categories) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // Number of columns
        crossAxisSpacing: 10.0, // Horizontal space between items
        mainAxisSpacing: 10.0, // Vertical space between items
        childAspectRatio: 1.0, // Makes the cells square
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = _selectedCategory?.key == category.key;

        return GestureDetector(
          onTap: () async {
            setState(() {
              _selectedCategory = category;
            });
            await _showAddTransactionSheet(category);
            setState(() {
              _selectedCategory = null;
            });
          },
          onLongPress: () {
            // You can add your confirmation dialog back here if you wish
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Delete Category'),
                content: Text("Are you sure you want to delete the '${category.name}' category?"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () {
                      context.read<CategoryBloc>().add(DeleteCategory(category.key));
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _animationController,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(_animationController),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            IconData(category.iconCodePoint, fontFamily: category.fontFamily ?? 'MaterialIcons'),
                            size: 32,
                            color: Colors.black87,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            style: GoogleFonts.poppins(fontSize: 13),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        );
      },
    );
  }

  Future<void> _showAddTransactionSheet(CategoryModel category) async {
    // ... This method remains unchanged
    if (widget.existingTransaction != null) {
      final txn = widget.existingTransaction!;
      _amountController.text = txn.amount.toString();
      _noteController.text = txn.note;
      selectedDate = txn.date;
    } else {
      _amountController.clear();
      _noteController.clear();
      selectedDate = DateTime.now();
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Wrap(
            children: [
              Center(
                child: Text(
                  "${widget.existingTransaction != null ? 'Update' : 'Add'} ${category.name} Transaction",
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
              _buildTransactionForm(context, category),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionForm(BuildContext context, CategoryModel category) {
    // ... This method remains unchanged
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Amount",
            prefixIcon: Icon(Icons.currency_rupee),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            labelText: "Note",
            prefixIcon: Icon(Icons.notes),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.date_range, size: 20),
            const SizedBox(width: 8),
            Text(
              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
              style: GoogleFonts.poppins(),
            ),
            const Spacer(),
            TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
              child: const Text("Change"),
            )
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_amountController.text) ?? 0.0;
              final note = _noteController.text.trim();
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid amount")),
                );
                return;
              }
              if (widget.existingTransaction != null) {
                final updatedTransaction = TransactionModel(
                  id: widget.existingTransaction!.id,
                  amount: amount,
                  note: note,
                  date: selectedDate,
                  categoryName: category.name,
                  isIncome: isIncome,
                  icon: category.iconCodePoint,
                );
                updatedTransaction.id = widget.existingTransaction!.key;
                context.read<TransactionBloc>().add(UpdateTransaction(updatedTransaction));
              } else {
                final newTransaction = TransactionModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  amount: amount,
                  note: note,
                  date: selectedDate,
                  categoryName: category.name,
                  isIncome: isIncome,
                  icon: category.iconCodePoint,
                );
                context.read<TransactionBloc>().add(AddTransaction(newTransaction));
              }
              Navigator.pop(context);
              if (widget.existingTransaction != null) {
                Navigator.pop(context);
              }
            },
            child: Text(widget.existingTransaction != null ? 'Update Transaction' : 'Add Transaction'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
