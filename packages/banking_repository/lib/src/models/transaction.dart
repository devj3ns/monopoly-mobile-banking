import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../banking_repository.dart';

class Transaction extends Equatable {
  const Transaction({
    this.fromUser,
    this.toUser,
    required this.amount,
    required this.timestamp,
  }) : assert(fromUser != null || toUser != null);

  @override
  List<Object?> get props => [fromUser, toUser, amount, timestamp];

  /// The name of the user wo sent the money. If null, the money came from the bank.
  final User? fromUser;

  /// The name of the user wo received the money. If null, the money went to the bank.
  final User? toUser;

  /// The amount of money which was sent.
  final int amount;

  // todo: use server timestamp!
  /// The timestamp when the transaction took place.
  final DateTime timestamp;

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
    };
  }
}