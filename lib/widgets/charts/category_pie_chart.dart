import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/services/hive_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryPieChartView extends StatefulWidget {
  const CategoryPieChartView({super.key});

  @override
  State<CategoryPieChartView> createState() => _CategoryPieChartViewState();
}

class _CategoryPieChartViewState extends State<CategoryPieChartView> {
  DateTime _selectedMonth = DateTime.now();

  Map<String, double> _getCategoryWiseTotals(List<TransactionModel> transactions) {
    final Map<String, double> categoryTotals = {};
    for (var txn in transactions) {
      if (!txn.isIncome && txn.date.month == _selectedMonth.month && txn.date.year == _selectedMonth.year) {
        categoryTotals[txn.categoryName] = (categoryTotals[txn.categoryName] ?? 0) + txn.amount;
      }
    }
    return categoryTotals;
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> data) {
    final total = data.values.fold(0.0, (sum, item) => sum + item);
    final List<Color> availableColors = [
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.brown,
      Colors.indigo,
    ];

    int colorIndex = 0;

    return data.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final section = PieChartSectionData(
        value: entry.value,
        title: "${percentage.toStringAsFixed(1)}%",
        color: availableColors[colorIndex % availableColors.length],
        radius: 70,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        badgeWidget: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(entry.key, style: const TextStyle(fontSize: 10)),
        ),
        badgePositionPercentageOffset: 1.2,
      );
      colorIndex++;
      return section;
    }).toList();
  }

  void _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Month',
      fieldHintText: 'Month/Year',
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() => _selectedMonth = DateTime(picked.year, picked.month));
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTxns = HiveManager.getAllTransactions();
    final filtered = _getCategoryWiseTotals(allTxns);

    return Column(
      children: [
        Row(
          children: [
            const Text("Select Month:"),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month, size: 16),
              onPressed: _pickMonth,
              label: Text(DateFormat.yMMM().format(_selectedMonth)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (filtered.isEmpty)
          const Text("No expenses for selected month.")
        else
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(filtered),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
      ],
    );
  }
}
