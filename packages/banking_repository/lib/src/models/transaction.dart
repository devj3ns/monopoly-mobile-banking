import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

enum TransactionType {
  fromBank,
  toBank,
  toPlayer,
  toFreeParking,
  fromFreeParking,
  fromSalary
}

extension StringToTransactionType on String {
  TransactionType toTransactionType() {
    return TransactionType.values.firstWhere((e) => e.toString() == this);
  }
}

class Transaction extends Equatable {
  const Transaction({
    this.fromUserId,
    this.toUserId,
    required this.amount,
    required this.timestamp,
    required this.type,
  }) : assert(fromUserId != null || toUserId != null);

  const Transaction.fromBank({
    required String toUserId,
    required int amount,
    required DateTime timestamp,
  }) : this(
          toUserId: toUserId,
          amount: amount,
          timestamp: timestamp,
          type: TransactionType.fromBank,
        );

  const Transaction.toBank({
    required String fromUserId,
    required int amount,
    required DateTime timestamp,
  }) : this(
          fromUserId: fromUserId,
          amount: amount,
          timestamp: timestamp,
          type: TransactionType.toBank,
        );

  const Transaction.toPlayer({
    required String fromUserId,
    required String toUserId,
    required int amount,
    required DateTime timestamp,
  }) : this(
          fromUserId: fromUserId,
          toUserId: toUserId,
          amount: amount,
          timestamp: timestamp,
          type: TransactionType.toPlayer,
        );

  const Transaction.toFreeParking({
    required String fromUserId,
    required int amount,
    required DateTime timestamp,
  }) : this(
          fromUserId: fromUserId,
          amount: amount,
          timestamp: timestamp,
          type: TransactionType.toFreeParking,
        );

  const Transaction.fromFreeParking({
    required String toUserId,
    required int freeParkingMoney,
    required DateTime timestamp,
  }) : this(
          toUserId: toUserId,
          amount: freeParkingMoney,
          timestamp: timestamp,
          type: TransactionType.fromFreeParking,
        );

  const Transaction.fromSalary({
    required String toUserId,
    required int salary,
    required DateTime timestamp,
  }) : this(
          toUserId: toUserId,
          amount: salary,
          timestamp: timestamp,
          type: TransactionType.fromSalary,
        );

  @override
  List<Object?> get props => [fromUserId, toUserId, amount, timestamp];

  /// The user id of the user who sent the money.
  final String? fromUserId;

  /// The user id of the user who received the money.
  final String? toUserId;

  /// The amount of money which was sent.
  final int amount;

  /// The timestamp when the transaction took place.
  final DateTime timestamp;

  /// The type of this transaction.
  final TransactionType type;

  static Transaction fromJson(Map<String, dynamic> json) {
    return Transaction(
      fromUserId: pick(json, 'fromUserId').asStringOrNull(),
      toUserId: pick(json, 'toUserId').asStringOrNull(),
      amount: pick(json, 'amount').asIntOrThrow(),
      timestamp: pick(json, 'timestamp').asFirestoreTimeStampOrThrow().toDate(),
      type: (pick(json, 'type').asStringOrThrow()).toTransactionType(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'amount': amount,
      'timestamp': timestamp,
      'type': type.toString(),
    };
  }
}
