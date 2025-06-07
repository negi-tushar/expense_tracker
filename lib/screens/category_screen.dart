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

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  bool isIncome = false;

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // If we are editing, pre-fill the state from the transaction
    if (widget.existingTransaction != null) {
      final txn = widget.existingTransaction!;
      setState(() {
        isIncome = txn.isIncome;
        // The rest of the data will be pre-filled when the bottom sheet is shown
      });
    }
  }

  // REMOVED: No longer need local lists
  // final List<CategoryModel> expenseCategories = [];
  // final List<CategoryModel> incomeCategories = [];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // REMOVED: This logic moves inside the BlocBuilder
    // final categories = isIncome ? incomeCategories : expenseCategories;

    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionLoaded) {
          Navigator.of(context).popUntil((route) => route.isFirst); // Pop back to HomeScreen
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
                // Assuming you have a named route for AddCategoryScreen
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCategoryScreen()));
              },
            ),
          ],
        ),
        // MODIFIED: Wrap the body's content with a BlocBuilder
        body: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            // Handle Loading State
            if (state is CategoryLoading || state is CategoryInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            // Handle Error State
            if (state is CategoryError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            // Handle Loaded State
            if (state is CategoryLoaded) {
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
                        : _buildCategoryWrap(categories),
                  ),
                ],
              );
            }

            // Fallback for any other state
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
          });
        },
        children: [
          Text("Expense", style: GoogleFonts.poppins()),
          Text("Income", style: GoogleFonts.poppins()),
        ],
      ),
    );
  }

  Widget _buildCategoryWrap(List<CategoryModel> categories) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        children: categories.map((category) {
          return GestureDetector(
            onTap: () => _showAddTransactionSheet(category),
            onLongPress: () {
              context.read<CategoryBloc>().add(DeleteCategory(category.key));
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // _showAddTransactionSheet and _buildTransactionForm methods remain the same...
  void _showAddTransactionSheet(CategoryModel category) {
    // If we are editing, pre-fill the controllers
    if (widget.existingTransaction != null) {
      final txn = widget.existingTransaction!;
      _amountController.text = txn.amount.toString();
      _noteController.text = txn.note;
      selectedDate = txn.date;
    } else {
      // If adding a new one, clear the controllers
      _amountController.clear();
      _noteController.clear();
      selectedDate = DateTime.now();
    }

    showModalBottomSheet(
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
                  "Add ${category.name} Transaction",
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
                // UPDATE EXISTING TRANSACTION
                final updatedTransaction = TransactionModel(
                  id: widget.existingTransaction!.id, // Use the original ID
                  amount: amount,
                  note: note,
                  date: selectedDate,
                  categoryName: category.name, // The newly selected category name
                  isIncome: isIncome,
                  icon: category.iconCodePoint, // The newly selected category icon
                );
                // The 'key' from HiveObject will be preserved automatically
                updatedTransaction.id = widget.existingTransaction!.id;
                context.read<TransactionBloc>().add(UpdateTransaction(updatedTransaction));
              } else {
                // ADD NEW TRANSACTION (your existing logic)
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

              Navigator.pop(context); // Close bottom sheet
              // If editing, pop twice to go back to home screen
              if (widget.existingTransaction != null) {
                Navigator.pop(context);
              }
            },
            child: const Text("Add Transaction"),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
