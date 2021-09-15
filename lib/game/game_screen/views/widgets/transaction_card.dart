import 'package:banking_repository/banking_repository.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../authentication/cubit/auth_cubit.dart';
import '../../../../extensions.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    Key? key,
    required this.transaction,
    required this.game,
  }) : super(key: key);

  final Transaction transaction;
  final Game game;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;
    final transactionConcernsMe =
        transaction.fromUserId == user.id || transaction.toUserId == user.id;

    String getText() {
      String toUserNameOrYou() => transaction.toUserId == user.id
          ? 'you'
          : game.getPlayer(transaction.toUserId!).name;
      String fromUserNameOrYou() => transaction.fromUserId == user.id
          ? 'you'
          : game.getPlayer(transaction.fromUserId!).name;
      final amount = context.formatMoneyBalance(transaction.amount);

      switch (transaction.type) {
        case TransactionType.fromBank:
          return '${toUserNameOrYou()} received $amount from the bank.'
              .capitalize();
        case TransactionType.toBank:
          return '${fromUserNameOrYou()} payed $amount to the bank.'
              .capitalize();
        case TransactionType.toPlayer:
          return '${fromUserNameOrYou()} payed ${toUserNameOrYou()} $amount.'
              .capitalize();
        case TransactionType.toFreeParking:
          return '${fromUserNameOrYou()} payed $amount to free parking.'
              .capitalize();
        case TransactionType.fromFreeParking:
          return '${toUserNameOrYou()} received the free parking money ($amount).'
              .capitalize();
        case TransactionType.fromSalary:
          final involvedInTransaction = transaction.fromUserId == user.id ||
              transaction.toUserId == user.id;
          final yourOrHis = involvedInTransaction ? 'your' : 'his';
          return '${toUserNameOrYou()} received $yourOrHis salary ($amount).'
              .capitalize();
      }
    }

    return Card(
      shape: transactionConcernsMe
          ? RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(5),
            )
          : null,
      child: ListTile(
        title: Text(
          getText(),
          style: TextStyle(
            fontWeight:
                transactionConcernsMe ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: Text(
          transaction.timestamp.format('Hms'),
          style: TextStyle(
            color: Colors.grey,
            fontWeight:
                transactionConcernsMe ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
