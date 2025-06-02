import 'package:expense_tracker/models/categorymodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  bool isIncome = false;

  final List<CategoryModel> expenseCategories = [
    CategoryModel(name: 'Food', icon: Icons.fastfood),
    CategoryModel(name: 'Transport', icon: Icons.directions_car),
    CategoryModel(name: 'Shopping', icon: Icons.shopping_bag),
    CategoryModel(name: 'Rent', icon: Icons.home),
  ];

  final List<CategoryModel> incomeCategories = [
    CategoryModel(name: 'Salary', icon: Icons.attach_money),
    CategoryModel(name: 'Bonus', icon: Icons.card_giftcard),
    CategoryModel(name: 'Investments', icon: Icons.trending_up),
  ];

  @override
  Widget build(BuildContext context) {
    final categories = isIncome ? incomeCategories : expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Category', style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Category",
            onPressed: () {
              // Show dialog or navigate to add category
            },
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
          onTap: () {
            _showAddTransactionSheet(category);
          },
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
                Icon(category.icon, size: 28, color: Colors.black87),
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

  Widget _buildTransactionForm(CategoryModel category) {
    final _amountController = TextEditingController();
    final _noteController = TextEditingController();
    DateTime selectedDate = DateTime.now();

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
                  selectedDate = picked;
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
              // Save to Hive or dispatch to BLoC
              Navigator.pop(context);
            },
            child: const Text("Add Transaction"),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showAddTransactionSheet(CategoryModel category) {
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
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTransactionForm(category),
            ],
          ),
        );
      },
    );
  }
}
