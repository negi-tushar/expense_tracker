import 'package:expense_tracker/models/transaction_model.dart';

abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final TransactionModel transaction;

  AddTransaction(this.transaction);
}

class DeleteTransaction extends TransactionEvent {
  final String transactionId;
  DeleteTransaction(this.transactionId);
}

class UpdateTransaction extends TransactionEvent {
  final TransactionModel transaction;
  UpdateTransaction(this.transaction);
}
