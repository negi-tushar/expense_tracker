import 'package:expense_tracker/blocs/transactions/transaction_event.dart';
import 'package:expense_tracker/blocs/transactions/transaction_state.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/services/hive_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
  }

  Future<void> _onLoadTransactions(LoadTransactions event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      emit(TransactionLoaded(getAllTransactions()));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(AddTransaction event, Emitter<TransactionState> emit) async {
    try {
      await HiveManager.addTransaction(event.transaction);

      emit(TransactionLoaded(getAllTransactions()));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(DeleteTransaction event, Emitter<TransactionState> emit) async {
    try {
      await HiveManager.deleteTransaction(event.transactionId);
      emit(TransactionLoaded(getAllTransactions()));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onUpdateTransaction(UpdateTransaction event, Emitter<TransactionState> emit) async {
    try {
      await HiveManager.updateTransaction(event.transaction);
      emit(TransactionLoaded(getAllTransactions()));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  List<TransactionModel> getAllTransactions() {
    final transactions = HiveManager.getAllTransactions();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }
}
