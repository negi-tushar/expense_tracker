import 'package:expense_tracker/blocs/transactions/transaction_bloc.dart';
import 'package:expense_tracker/blocs/transactions/transaction_event.dart';
import 'package:expense_tracker/blocs/transactions/transaction_state.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/screens/category_screen.dart';
import 'package:expense_tracker/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  initState() {
    context.read<TransactionBloc>().add(LoadTransactions());
    super.initState();
  }

  double _getTotalIncome(List<TransactionModel> transactions) {
    return transactions.where((tx) => tx.isIncome).fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double _getTotalExpense(List<TransactionModel> transactions) {
    return transactions.where((tx) => !tx.isIncome).fold(0.0, (sum, tx) => sum + tx.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Expense Tracker", style: GoogleFonts.poppins(fontSize: 18)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      drawer: AppDrawer(
        onSelectMenu: (menuId) {
          switch (menuId) {
            case "home":
              // Already on home, just close drawer
              break;
            case "categories":
              Navigator.push(context, MaterialPageRoute(builder: (_) => const Text("data")));
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategorySelectionScreen()),
          );
        },
        label: Text("Add Transaction", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.black87,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TransactionLoaded) {
              final transactions =
                  state.transactions.where((items) => items.date.month == DateTime.now().month).toList();
              final totalIncome = _getTotalIncome(transactions);
              final totalExpense = _getTotalExpense(transactions);
              final totalBalance = totalIncome - totalExpense;

              return Column(
                children: [
                  // Balance Text at top
                  Column(
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
                        "₹${totalBalance.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
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

                  // Your existing grouped transactions list here...
                  ..._buildGroupedTransactionList(transactions),
                ],
              );
            } else if (state is TransactionError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return Container(
                color: Colors.red,
                width: 400,
                height: 300,
              );
            }
          },
        ),
      ),
    );
  }

  List<Widget> _buildGroupedTransactionList(List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> groupedTransactions = {};
    for (var tx in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(tx.date);
      groupedTransactions.putIfAbsent(dateKey, () => []).add(tx);
    }

    return groupedTransactions.entries.map((entry) {
      final date = DateTime.parse(entry.key);
      final formattedDate = DateFormat('MMMM dd, yyyy').format(date);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            margin: const EdgeInsets.only(bottom: 10),
            child: Text(
              " $formattedDate",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          ...entry.value.map((txn) {
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: .2,
              margin: const EdgeInsets.only(bottom: 10),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: txn.note.isNotEmpty
                    ? Text(
                        txn.note,
                        style: const TextStyle(color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: Text(
                  "${txn.isIncome ? '+' : '-'}₹${txn.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: txn.isIncome ? Colors.green : Colors.red,
                  ),
                ),
              ),
            );
          }),
        ],
      );
    }).toList();
  }

  Widget _summaryCard(String title, double amount, Color color, IconData icon) {
    return Expanded(
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
              Text("₹${amount.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
