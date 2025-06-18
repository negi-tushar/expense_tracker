import 'package:expense_tracker/blocs/transactions/transaction_bloc.dart';
import 'package:expense_tracker/blocs/transactions/transaction_event.dart';
import 'package:expense_tracker/blocs/transactions/transaction_state.dart';
import 'package:expense_tracker/constants/extension.dart'; // Ensure this extension is correctly imported
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/screens/add_category_screen.dart';
import 'package:expense_tracker/screens/category_screen.dart';
import 'package:expense_tracker/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _animationButtonController;

  late int _selectedMonth;
  late int _selectedYear;

  @override
  initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _animationController.forward();

    // Initialize with current month and year
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;

    // Load transactions initially (will be filtered in BlocBuilder)
    context.read<TransactionBloc>().add(LoadTransactions());
    _animationButtonController.forward();

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationButtonController.dispose();
    super.dispose();
  }

  double _getTotalIncome(List<TransactionModel> transactions) {
    return transactions.where((tx) => tx.isIncome).fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double _getTotalExpense(List<TransactionModel> transactions) {
    return transactions.where((tx) => !tx.isIncome).fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Helper method to get month names (1-indexed for direct use with DateTime.month)
  List<String> get _monthNames {
    // DateFormat.MMMM().dateSymbols.STANDALONEMASULINE is 0-indexed for Jan, Feb, etc.
    // So for 1-indexed month numbers, we use index.
    return DateFormat.MMMM().dateSymbols.MONTHS.toList();
  }

  // Helper method to get a list of years (e.g., current year +/- 5)
  List<int> get _years {
    final currentYear = DateTime.now().year;
    return List<int>.generate(11, (i) => currentYear - 5 + i); // 5 years before, current, 5 years after
  }

  // --- NEW: Unified Filter Bottom Sheet Function ---
  Future<void> _showFilterBottomSheet(BuildContext context) async {
    final Map<String, int>? pickedDates = await showModalBottomSheet<Map<String, int>>(
      context: context,
      isScrollControlled: true, // Allows the sheet to take up more than half the screen
      backgroundColor: Colors.transparent, // For rounded corners to be visible
      builder: (BuildContext context) {
        return _FilterSelectionSheet(
          initialMonth: _selectedMonth,
          initialYear: _selectedYear,
          monthNames: _monthNames,
          years: _years,
        );
      },
    );

    // If dates were picked (not cancelled), update the state
    if (pickedDates != null) {
      setState(() {
        _selectedMonth = pickedDates['month']!;
        _selectedYear = pickedDates['year']!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Expense Tracker", style: GoogleFonts.poppins(fontSize: 18)),
        elevation: 1,
        // --- NEW: Filter Icon in AppBar Actions ---
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list), // Filter icon
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'Filter Transactions',
          ),
          // Optional: A button to reset filter to current month/year if not already selected
          if (_selectedMonth != DateTime.now().month || _selectedYear != DateTime.now().year)
            IconButton(
              icon: const Icon(Icons.refresh), // Reset icon
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime.now().month;
                  _selectedYear = DateTime.now().year;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filter reset to current month')),
                );
              },
              tooltip: 'Reset Filter',
            ),
        ],
      ),
      drawer: AppDrawer(
        onSelectMenu: (menuId) {
          switch (menuId) {
            case "home":
              // Already on home, just close drawer
              break;
            case "categories":
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCategoryScreen()));
              break;
            case "reports":
              Navigator.pushNamed(context, '/reports');
              // Navigator.push to reports screen
              break;
            case "settings":
              // Navigator.push to settings screen
              break;
            case "about":
              // Show about dialog or screen
              break;
          }
        },
      ),
      floatingActionButton: AnimatedBuilder(
          animation: _animationButtonController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _animationButtonController,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CategorySelectionScreen()),
                  );
                },
                label: Text("Add Transaction",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white)),
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                backgroundColor: Colors.black87,
              ),
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TransactionLoaded) {
              // --- Filter transactions based on selected month and year ---
              final filteredTransactions = state.transactions.where((tx) {
                return tx.date.month == _selectedMonth && tx.date.year == _selectedYear;
              }).toList();

              final totalIncome = _getTotalIncome(filteredTransactions);
              final totalExpense = _getTotalExpense(filteredTransactions);
              final totalBalance = totalIncome - totalExpense;

              return Column(
                children: [
                  // Balance Text at top
                  AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _animationController,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.5),
                              end: Offset.zero,
                            ).animate(_animationController),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Balance",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "₹${totalBalance.toStringAsFixed(2).toIndianNumberFormat()}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  const SizedBox(height: 16),
                  // Income and Expense summary cards
                  Row(
                    children: [
                      _summaryCard("Income", totalIncome, Colors.green, Icons.arrow_downward),
                      const SizedBox(width: 12),
                      _summaryCard("Expense", totalExpense, Colors.red, Icons.arrow_upward),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Display message if no transactions for the selected period
                  if (filteredTransactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'No transactions for this period.', // Simplified message as period is shown above
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    // Your existing grouped transactions list here...
                    ..._buildGroupedTransactionList(filteredTransactions),
                ],
              );
            } else if (state is TransactionError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              // Fallback for initial unhandled states
              return const Center(child: Text('Please add your first transaction!'));
            }
          },
        ),
      ),
    );
  }

  List<Widget> _buildGroupedTransactionList(List<TransactionModel> transactions) {
    // Sort transactions by date in descending order (most recent first)
    transactions.sort((a, b) => b.date.compareTo(a.date));

    final Map<String, List<TransactionModel>> groupedTransactions = {};
    for (var tx in transactions) {
      // Use the full date (yyyy-MM-dd) as the key for grouping by day
      final dateKey = DateFormat('yyyy-MM-dd').format(tx.date);
      groupedTransactions.putIfAbsent(dateKey, () => []).add(tx);
    }

    return groupedTransactions.entries.map((entry) {
      final date = DateTime.parse(entry.key);
      // Format the date for display (e.g., "June 18, 2024")
      final formattedDate = DateFormat('MMMM dd,yyyy').format(date); // Corrected format for year

      return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _animationController,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(_animationController),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        formattedDate, // Display the formatted date
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    ...entry.value.map((txn) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        child: Slidable(
                          key: ValueKey(txn.id),
                          endActionPane: ActionPane(
                            extentRatio: 0.5,
                            motion: const ScrollMotion(),
                            children: [
                              // EDIT ACTION
                              SlidableAction(
                                spacing: 2,
                                onPressed: (context) {
                                  // Navigate to Category screen for editing
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CategorySelectionScreen(existingTransaction: txn),
                                    ),
                                  );
                                },
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: 'Edit',
                              ),
                              // DELETE ACTION
                              SlidableAction(
                                spacing: 2,
                                onPressed: (context) {
                                  context.read<TransactionBloc>().add(DeleteTransaction(txn.id));
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: .2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: txn.isIncome ? Colors.green[100] : Colors.red[100],
                                child: Icon(
                                  IconData(txn.icon, fontFamily: 'MaterialIcons'),
                                  color: Colors.black,
                                ),
                              ),
                              title: Text(
                                txn.categoryName,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: txn.note.isNotEmpty
                                  ? Text(
                                      txn.note,
                                      style: GoogleFonts.poppins(color: Colors.black54),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null,
                              trailing: Text(
                                "${txn.isIncome ? '+' : '-'}₹${txn.amount.toStringAsFixed(2).toIndianNumberFormat()}",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: txn.isIncome ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          });
    }).toList();
  }

  Widget _summaryCard(String title, double amount, Color color, IconData icon) {
    return Expanded(
      child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _animationController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(_animationController),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      children: [
                        Icon(icon, color: color, size: 28),
                        const SizedBox(height: 6),
                        Text(title, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
                        const SizedBox(height: 6),
                        Text("₹${amount.toStringAsFixed(2).toIndianNumberFormat()}",
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}

// --- NEW WIDGET: _FilterSelectionSheet ---
// This StatefulWidget will be shown as a modal bottom sheet for filter selection.
class _FilterSelectionSheet extends StatefulWidget {
  final int initialMonth;
  final int initialYear;
  final List<String> monthNames;
  final List<int> years;

  const _FilterSelectionSheet({
    required this.initialMonth,
    required this.initialYear,
    required this.monthNames,
    required this.years,
  });

  @override
  __FilterSelectionSheetState createState() => __FilterSelectionSheetState();
}

class __FilterSelectionSheetState extends State<_FilterSelectionSheet> {
  late int _tempSelectedMonth;
  late int _tempSelectedYear;
  late ScrollController _monthScrollController;
  late ScrollController _yearScrollController;

  @override
  void initState() {
    super.initState();
    _tempSelectedMonth = widget.initialMonth;
    _tempSelectedYear = widget.initialYear;

    // Initialize scroll controllers to current selection for better UX
    _monthScrollController = ScrollController(
      initialScrollOffset: (widget.initialMonth - 1) * 56.0, // Assuming each ListTile is roughly 56 logical pixels tall
    );
    _yearScrollController = ScrollController(
      initialScrollOffset: (widget.years.indexOf(widget.initialYear)) * 56.0,
    );

    // After the first frame, ensure we jump to the correct position
    // and clamp to prevent going beyond scrollable extent.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_monthScrollController.hasClients) {
        final maxMonthScroll = _monthScrollController.position.maxScrollExtent;
        final targetMonthOffset = (widget.initialMonth - 1) * 56.0;
        _monthScrollController.jumpTo(targetMonthOffset.clamp(0.0, maxMonthScroll));
      }
      if (_yearScrollController.hasClients) {
        final maxYearScroll = _yearScrollController.position.maxScrollExtent;
        final targetYearOffset = (widget.years.indexOf(widget.initialYear)) * 56.0;
        _yearScrollController.jumpTo(targetYearOffset.clamp(0.0, maxYearScroll));
      }
    });
  }

  @override
  void dispose() {
    _monthScrollController.dispose();
    _yearScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)), // Rounded top corners
      ),
      height: MediaQuery.of(context).size.height * 0.75, // Adjust height as needed for content
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Filter Transactions',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // Separator
          Divider(color: Colors.grey.shade300, height: 1),
          Expanded(
            child: Row(
              children: [
                // Month List
                Expanded(
                  child: ListView.builder(
                    controller: _monthScrollController, // Attach controller
                    itemCount: widget.monthNames.length,
                    itemBuilder: (context, index) {
                      final monthNumber = index + 1; // Months are 1-indexed (Jan=1)
                      return ListTile(
                        title: Text(
                          widget.monthNames[index],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: _tempSelectedMonth == monthNumber ? FontWeight.bold : FontWeight.normal,
                            color: _tempSelectedMonth == monthNumber ? Colors.black87 : Colors.grey[800],
                          ),
                        ),
                        trailing:
                            _tempSelectedMonth == monthNumber ? const Icon(Icons.check, color: Colors.green) : null,
                        onTap: () {
                          setState(() {
                            _tempSelectedMonth = monthNumber;
                          });
                        },
                      );
                    },
                  ),
                ),
                // Vertical Divider between month and year lists
                VerticalDivider(color: Colors.grey.shade300, thickness: 1, width: 1),
                // Year List
                Expanded(
                  child: ListView.builder(
                    controller: _yearScrollController, // Attach controller
                    itemCount: widget.years.length,
                    itemBuilder: (context, index) {
                      final year = widget.years[index];
                      return ListTile(
                        title: Text(
                          year.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: _tempSelectedYear == year ? FontWeight.bold : FontWeight.normal,
                            color: _tempSelectedYear == year ? Colors.black87 : Colors.grey[800],
                          ),
                        ),
                        trailing: _tempSelectedYear == year ? const Icon(Icons.check, color: Colors.green) : null,
                        onTap: () {
                          setState(() {
                            _tempSelectedYear = year;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Separator
          Divider(color: Colors.grey.shade300, height: 1),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close without applying filter
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Pop the sheet and return the selected month and year
                      Navigator.pop(context, {
                        'month': _tempSelectedMonth,
                        'year': _tempSelectedYear,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87, // Matches your FAB
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Apply Filter', style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
