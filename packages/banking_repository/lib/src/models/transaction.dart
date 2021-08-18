import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

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

  Transaction.fromBank({
    required String toUserId,
    required int amount,
  }) : this(
          toUserId: toUserId,
          amount: amount,
          timestamp: DateTime.now(),
          type: TransactionType.fromBank,
        );

  Transaction.toBank({
    required String fromUserId,
    required int amount,
  }) : this(
          fromUserId: fromUserId,
          amount: amount,
          timestamp: DateTime.now(),
          type: TransactionType.toBank,
        );

  Transaction.toPlayer({
    required String fromUserId,
    required String toUserId,
    required int amount,
  }) : this(
          fromUserId: fromUserId,
          toUserId: toUserId,
          amount: amount,
          timestamp: DateTime.now(),
          type: TransactionType.toPlayer,
        );

  Transaction.toFreeParking({
    required String fromUserId,
    required int amount,
  }) : this(
          fromUserId: fromUserId,
          amount: amount,
          timestamp: DateTime.now(),
          type: TransactionType.toFreeParking,
        );

  Transaction.fromFreeParking({
    required String toUserId,
    required int freeParkingMoney,
  }) : this(
          toUserId: toUserId,
          amount: freeParkingMoney,
          timestamp: DateTime.now(),
          type: TransactionType.fromFreeParking,
        );

  Transaction.fromSalary({
    required String toUserId,
    required int salary,
  }) : this(
          toUserId: toUserId,
          amount: salary,
          timestamp: DateTime.now(),
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
      fromUserId: json['fromUserId'] as String?,
      toUserId: json['toUserId'] as String?,
      amount: json['amount'] as int,
      // When using FieldValue.serverTimestamp(), the timestamp is null for a split second before the server sets it to the actual server timestamp.
      // See https://medium.com/firebase-developers/the-secrets-of-firestore-fieldvalue-servertimestamp-revealed-29dd7a38a82b
      //
      // To avoid an exception set the timestamp to the local time in this case:
      timestamp: json['timestamp'] == null
          ? DateTime.now()
          : (json['timestamp'] as Timestamp).toDate(),
      type: (json['type'] as String).toTransactionType(),
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
