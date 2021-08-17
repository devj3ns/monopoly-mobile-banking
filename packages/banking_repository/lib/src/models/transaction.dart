import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

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
    this.fromUser,
    this.toUser,
    required this.amount,
    required this.timestamp,
    required this.type,
  }) : assert(fromUser != null || toUser != null);

  Transaction.fromBank({
    required User toUser,
    required int amount,
  }) : this(
          toUser: toUser,
          amount: amount,
          timestamp: DateTime.now(),
          type: TransactionType.fromBank,
        );

  Transaction.toBank({
    required User fromUser,
    required int amount,
  }) : this(
          fromUser: fromUser,
          amount: amount,
          timestamp: DateTime.now(),
          type: TransactionType.toBank,
        );

  Transaction.toPlayer({
    required User fromUser,
    required User toUser,
    required int amount,
  }) : this(
          fromUser: fromUser,
          toUser: toUser,
          amount: amount,
          timestamp: DateTime.now(),
          type: TransactionType.toPlayer,
        );

  Transaction.toFreeParking({
    required User fromUser,
    required int amount,
  }) : this(
          fromUser: fromUser,
          amount: amount,
          timestamp: DateTime.now(),
          type: TransactionType.toFreeParking,
        );

  Transaction.fromFreeParking({
    required User toUser,
    required int freeParkingMoney,
  }) : this(
          toUser: toUser,
          amount: freeParkingMoney,
          timestamp: DateTime.now(),
          type: TransactionType.fromFreeParking,
        );

  Transaction.fromSalary({
    required User toUser,
    required int salary,
  }) : this(
          toUser: toUser,
          amount: salary,
          timestamp: DateTime.now(),
          type: TransactionType.fromSalary,
        );

  @override
  List<Object?> get props => [fromUser, toUser, amount, timestamp];

  /// The user wo sent the money.
  final User? fromUser;

  /// The user wo received the money.
  final User? toUser;

  /// The amount of money which was sent.
  final int amount;

  /// The timestamp when the transaction took place.
  final DateTime timestamp;

  /// The type of this transaction.
  final TransactionType type;

  static Transaction fromJson(Map<String, dynamic> json) {
    final fromUser = json['fromUserId'] != null && json['fromUserName'] != null
        ? User(
            id: json['fromUserId'] as String,
            name: json['fromUserName'] as String)
        : null;

    final toUser = json['toUserId'] != null && json['toUserName'] != null
        ? User(
            id: json['toUserId'] as String, name: json['toUserName'] as String)
        : null;

    return Transaction(
      fromUser: fromUser,
      toUser: toUser,
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
      'fromUserId': fromUser?.id,
      'fromUserName': fromUser?.name,
      'toUserId': toUser?.id,
      'toUserName': toUser?.name,
      'amount': amount,
      'timestamp': timestamp,
      'type': type.toString(),
    };
  }
}
