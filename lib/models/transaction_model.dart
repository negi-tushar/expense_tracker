import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  late String id; // unique id, e.g. UUID

  @HiveField(1)
  late String categoryName;

  @HiveField(2)
  late bool isIncome;

  @HiveField(3)
  late double amount;

  @HiveField(4)
  late String note;

  @HiveField(5)
  late DateTime date;
  @HiveField(6)
  late int icon;
  TransactionModel(
      {required this.id,
      required this.categoryName,
      required this.isIncome,
      required this.amount,
      required this.note,
      required this.date,
      required this.icon});
}
