import 'package:expense_tracker/screens/add_transactions_screen.dart';
import 'package:expense_tracker/screens/category_screen.dart';
import 'package:expense_tracker/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  final double totalBalance = 1234.56;
  final double income = 5000;
  final double expense = 3766;

  final Map<String, List<Map<String, dynamic>>> groupedTransactions = {
    "2025-06-02": [
      {"title": "Grocery", "amount": -50.00},
      {"title": "Cab Ride", "amount": -18.00},
    ],
    "2025-06-01": [
      {"title": "Salary", "amount": 2000.00},
      {"title": "Rent", "amount": -400.00},
    ],
    "2025-06-03": [
      {"title": "Salary", "amount": 2000.00},
      {"title": "Rent", "amount": -400.00},
    ],
    "2025-06-04": [
      {"title": "Salary", "amount": 2000.00},
      {"title": "Rent", "amount": -400.00},
    ],
  };

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
        child: Column(
          children: [
            // Top Balance Text
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
                  "\$${totalBalance.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            // Total Balance Card
            // Card(
            //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            //   elevation: 3,
            //   child: Padding(
            //     padding: const EdgeInsets.all(20.0),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text("Total Balance", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
            //         const SizedBox(height: 8),
            //         Text("\$${totalBalance.toStringAsFixed(2)}",
            //             style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600)),
            //       ],
            //     ),
            //   ),
            // ),
            const SizedBox(height: 16),

            // Income and Expense summary
            Row(
              children: [
                _summaryCard("Income", income, Colors.green, Icons.arrow_downward),
                const SizedBox(width: 12),
                _summaryCard("Expense", expense, Colors.red, Icons.arrow_upward),
              ],
            ),

            const SizedBox(height: 24),

            // Transactions Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Recent Transactions", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),

            // Grouped Transactions
            ...groupedTransactions.entries.map((entry) {
              DateTime date = DateTime.parse(entry.key);
              String formattedDate = DateFormat('MMMM dd, yyyy').format(date);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text("📅 $formattedDate", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  ...entry.value.map((tx) {
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: tx['amount'] > 0 ? Colors.green[100] : Colors.red[100],
                          child: Icon(
                            tx['amount'] > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                            color: tx['amount'] > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(tx['title'], style: GoogleFonts.poppins(fontSize: 14)),
                        trailing: Text(
                          "${tx['amount'] > 0 ? "+" : "-"} \$${tx['amount'].abs().toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: tx['amount'] > 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
              Text("\$${amount.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context, String label, IconData icon, Color color, bool isIncome) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTransactionScreen(isIncome: isIncome),
          ),
        );
      },
      icon: Icon(icon, size: 18),
      label: Text(label, style: GoogleFonts.poppins(fontSize: 12)),
    );
  }
}
