import 'package:expense_tracker/widgets/charts/balance_chart_view.dart';
import 'package:expense_tracker/widgets/charts/category_pie_chart.dart';
import 'package:expense_tracker/widgets/charts/monthly_bar_chart.dart';
import 'package:expense_tracker/widgets/charts/yearly_summary_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    "Monthly Income vs Expense",
    "Category-wise Expenses",
    "Balance Over Time",
    "Monthly Summary",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reports", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((title) => Tab(text: title)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MonthlyBarChartView(),
          CategoryPieChartView(),
          BalanceLineChartView(),
          YearlySummaryTableView(),
        ],
      ),
    );
  }
}
