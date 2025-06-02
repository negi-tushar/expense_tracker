import 'package:expense_tracker/services/hive_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyBarChartView extends StatelessWidget {
  const MonthlyBarChartView({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = HiveManager.getAllTransactions();

    // Group by month (e.g., '2025-01') and calculate totals
    final Map<String, Map<String, double>> monthlyData = {};

    for (var tx in transactions) {
      final monthKey = DateFormat('yyyy-MM').format(tx.date);
      monthlyData.putIfAbsent(monthKey, () => {'income': 0, 'expense': 0});

      if (tx.isIncome) {
        monthlyData[monthKey]!['income'] = monthlyData[monthKey]!['income']! + tx.amount;
      } else {
        monthlyData[monthKey]!['expense'] = monthlyData[monthKey]!['expense']! + tx.amount;
      }
    }

    final sortedKeys = monthlyData.keys.toList()..sort();
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final income = monthlyData[key]!['income'] ?? 0;
      final expense = monthlyData[key]!['expense'] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: income, color: Colors.green, width: 8),
            BarChartRodData(toY: expense, color: Colors.red, width: 8),
          ],
          barsSpace: 4,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text("Monthly Income vs Expense", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < sortedKeys.length) {
                          final key = sortedKeys[index];
                          final formatted = DateFormat('MMM').format(DateTime.parse("$key-01"));
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(formatted, style: const TextStyle(fontSize: 10)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
