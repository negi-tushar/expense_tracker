import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  // Dummy data for chart and balance
  final double totalBalance = 1234.56;
  final double income = 5000;
  final double expense = 3766;

  final List<PieChartSectionData> pieChartSections = [
    PieChartSectionData(
      color: Colors.redAccent,
      value: 40,
      title: 'Rent',
      radius: 50,
      titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    PieChartSectionData(
      color: Colors.blueAccent,
      value: 30,
      title: 'Food',
      radius: 50,
      titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    PieChartSectionData(
      color: Colors.greenAccent,
      value: 30,
      title: 'Others',
      radius: 50,
      titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Expense Tracker', style: GoogleFonts.poppins()),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Total Balance Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 6,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Balance', style: GoogleFonts.poppins(fontSize: 20, color: Colors.grey[700])),
                    SizedBox(height: 8),
                    Text('\$${totalBalance.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Income & Expense summary row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryCard('Income', income, Colors.green, Icons.arrow_downward),
                _summaryCard('Expense', expense, Colors.red, Icons.arrow_upward),
              ],
            ),
            SizedBox(height: 30),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(context, 'Add Expense', Icons.remove_circle, Colors.red),
                _actionButton(context, 'Add Income', Icons.add_circle, Colors.green),
                _actionButton(context, 'View History', Icons.history, Colors.blue),
              ],
            ),
            SizedBox(height: 30),

            // Pie Chart Card
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text('Expense Breakdown', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                      SizedBox(height: 20),
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: pieChartSections,
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, double amount, Color color, IconData icon) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 36),
              SizedBox(height: 8),
              Text(title, style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[700])),
              SizedBox(height: 8),
              Text('\$${amount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context, String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 5,
      ),
      onPressed: () {
        // TODO: Add navigation logic here
      },
      icon: Icon(icon, size: 20),
      label: Text(label, style: GoogleFonts.poppins(fontSize: 14)),
    );
  }
}
