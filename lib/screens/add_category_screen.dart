import 'package:expense_tracker/blocs/bloc/category_bloc.dart';
import 'package:expense_tracker/blocs/bloc/category_event.dart';
import 'package:expense_tracker/models/category_model.dart'; // ADDED
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // ADDED
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart'; // ADDED: Import the uuid package

const uuid = Uuid(); // ADDED: Create a uuid generator instance

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _nameController = TextEditingController();
  IconData? _selectedIcon;
  bool _isIncome = false; // ADDED: State to track category type

  // A predefined list of icons for the user to choose from
  final List<IconData> _icons = [
    Icons.card_travel,
    Icons.local_dining,
    Icons.movie,
    Icons.pets,
    Icons.phone_android,
    Icons.school,
    Icons.health_and_safety,
    Icons.fitness_center,
    Icons.music_note,
    Icons.house,
    Icons.flight,
    Icons.train,
    Icons.restaurant,
    Icons.cake,
    Icons.celebration,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ADDED: New widget for the Expense/Income toggle
  Widget _buildTypeToggle() {
    return Center(
      child: ToggleButtons(
        isSelected: [!_isIncome, _isIncome],
        borderRadius: BorderRadius.circular(10),
        fillColor: Colors.black,
        selectedColor: Colors.white,
        color: Colors.black87,
        constraints: const BoxConstraints(minHeight: 40, minWidth: 100),
        onPressed: (index) {
          setState(() {
            _isIncome = index == 1;
          });
        },
        children: [
          Text("Expense", style: GoogleFonts.poppins()),
          Text("Income", style: GoogleFonts.poppins()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Category', style: GoogleFonts.poppins()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Name TextField
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Category Name",
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ADDED: Call the toggle widget
            _buildTypeToggle(),
            const SizedBox(height: 24),

            // Icon Selection Grid
            Text(
              "Select an Icon",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: _icons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final icon = _icons[index];
                  final isSelected = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 30,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                // MODIFIED: Updated onPressed to use the BLoC
                onPressed: () {
                  final categoryName = _nameController.text.trim();
                  if (categoryName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a category name.")),
                    );
                    return;
                  }
                  if (_selectedIcon == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select an icon.")),
                    );
                    return;
                  }

                  // Create the new category model
                  final newCategory = CategoryModel(
                    name: categoryName,
                    iconCodePoint: _selectedIcon!.codePoint,
                    fontFamily: _selectedIcon!.fontFamily,
                    isIncome: _isIncome,
                  );

                  // Dispatch the event to the CategoryBloc
                  context.read<CategoryBloc>().add(AddCategory(newCategory));

                  // Go back to the previous screen
                  Navigator.of(context).pop();
                },
                child: Text('Save Category', style: GoogleFonts.poppins(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
