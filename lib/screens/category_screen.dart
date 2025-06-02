import 'package:expense_tracker/blocs/transactions/transaction_bloc.dart';
import 'package:expense_tracker/blocs/transactions/transaction_event.dart';
import 'package:expense_tracker/blocs/transactions/transaction_state.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  bool isIncome = false;

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  final List<CategoryModel> expenseCategories = [
    CategoryModel(name: 'Food', iconCodePoint: Icons.fastfood.codePoint, id: DateTime.now().microsecondsSinceEpoch),
    CategoryModel(
        name: 'Transport', iconCodePoint: Icons.directions_car.codePoint, id: DateTime.now().microsecondsSinceEpoch),
    CategoryModel(
        name: 'Shopping', iconCodePoint: Icons.shopping_bag.codePoint, id: DateTime.now().microsecondsSinceEpoch),
    CategoryModel(name: 'Rent', iconCodePoint: Icons.home.codePoint, id: DateTime.now().microsecondsSinceEpoch),
  ];

  final List<CategoryModel> incomeCategories = [
    CategoryModel(
        name: 'Salary', iconCodePoint: Icons.attach_money.codePoint, id: DateTime.now().microsecondsSinceEpoch),
    CategoryModel(
        name: 'Bonus', iconCodePoint: Icons.card_giftcard.codePoint, id: DateTime.now().microsecondsSinceEpoch),
    CategoryModel(
        name: 'Investments', iconCodePoint: Icons.trending_up.codePoint, id: DateTime.now().microsecondsSinceEpoch),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = isIncome ? incomeCategories : expenseCategories;
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
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            _buildToggleSwitch(),
            Expanded(child: _buildCategoryGrid(categories)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildCategoryGrid(List<CategoryModel> categories) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () => _showAddTransactionSheet(category),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  IconData(category.iconCodePoint, fontFamily: category.fontFamily ?? 'MaterialIcons'),
                  size: 28,
                  color: Colors.black87,
                ),
                const SizedBox(height: 6),
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
        );
      },
    );
  }

  void _showAddTransactionSheet(CategoryModel category) {
    _amountController.clear();
    _noteController.clear();
    selectedDate = DateTime.now();

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

              final transaction = TransactionModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  amount: amount,
                  note: note,
                  date: selectedDate,
                  categoryName: category.name,
                  isIncome: isIncome,
                  icon: category.iconCodePoint);

              context.read<TransactionBloc>().add(AddTransaction(transaction));
              Navigator.pop(context);
            },
            child: const Text("Add Transaction"),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
