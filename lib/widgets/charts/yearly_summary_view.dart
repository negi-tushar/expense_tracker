import 'package:expense_tracker/blocs/transactions/transaction_bloc.dart';
import 'package:expense_tracker/blocs/transactions/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class YearlySummaryTableView extends StatefulWidget {
  const YearlySummaryTableView({super.key});

  @override
  _YearlySummaryTableViewState createState() => _YearlySummaryTableViewState();
}

class _YearlySummaryTableViewState extends State<YearlySummaryTableView> {
  late int selectedYear;
  late List<int> availableYears;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedYear = now.year;
    availableYears = [selectedYear]; // Will update once data loads
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TransactionLoaded) {
          // Extract all transaction years for dropdown
          final yearsSet = state.transactions.map((tx) => tx.date.year).toSet();
          availableYears = yearsSet.toList()..sort((a, b) => b.compareTo(a));

          // Make sure selectedYear is valid
          if (!availableYears.contains(selectedYear) && availableYears.isNotEmpty) {
            selectedYear = availableYears.first;
          }

          // Prepare monthly summary arrays
          final incomeByMonth = List<double>.filled(12, 0);
          final expenseByMonth = List<double>.filled(12, 0);

          for (var tx in state.transactions) {
            if (tx.date.year == selectedYear) {
              final monthIndex = tx.date.month - 1;
              if (tx.isIncome) {
                incomeByMonth[monthIndex] += tx.amount;
              } else {
                expenseByMonth[monthIndex] += tx.amount;
              }
            }
          }

          // Calculate balance per month
          final balanceByMonth = List<double>.generate(
            12,
            (i) => incomeByMonth[i] - expenseByMonth[i],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Year selector dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Select Year:',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: selectedYear,
                      items: availableYears
                          .map((year) => DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedYear = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Table header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  columnWidths: const {
                    0: FixedColumnWidth(90),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                    3: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade200),
                      children: [
                        _buildCell('Month', isHeader: true),
                        _buildCell('Income', isHeader: true),
                        _buildCell('Expense', isHeader: true),
                        _buildCell('Balance', isHeader: true),
                      ],
                    ),
                    // Monthly data rows
                    ...List.generate(12, (i) {
                      final monthName = DateFormat.MMMM().format(DateTime(0, i + 1));
                      return TableRow(
                        children: [
                          _buildCell(monthName),
                          _buildCell('₹${incomeByMonth[i].toStringAsFixed(2)}', isIncome: true),
                          _buildCell('₹${expenseByMonth[i].toStringAsFixed(2)}', isExpense: true),
                          _buildCell('₹${balanceByMonth[i].toStringAsFixed(2)}',
                              isIncome: balanceByMonth[i] >= 0, isExpense: balanceByMonth[i] < 0),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          );
        } else if (state is TransactionError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCell(String text, {bool isHeader = false, bool isIncome = false, bool isExpense = false}) {
    Color textColor = Colors.black87;
    if (isIncome) textColor = Colors.green;
    if (isExpense) textColor = Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 14 : 13,
          color: textColor,
        ),
      ),
    );
  }
}
