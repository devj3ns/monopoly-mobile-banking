import 'package:banking_repository/banking_repository.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../authentication/cubit/auth_cubit.dart';
import '../../../../shared/extensions.dart';
import '../../../../shared/theme.dart';

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

    List<TextSpan> getTextSpans() {
      Player toPlayer() => game.getPlayer(transaction.toUserId!);
      Player fromPlayer() => game.getPlayer(transaction.fromUserId!);
      String toUserNameOrYou() => transaction.toUserId == user.id
          ? 'you'
          : game.getPlayer(transaction.toUserId!).name;
      String fromUserNameOrYou() => transaction.fromUserId == user.id
          ? 'you'
          : game.getPlayer(transaction.fromUserId!).name;
      final amount = context.formatMoneyBalance(transaction.amount);

      TextSpan toUserNameOrYouTextSpan({bool capitalize = false}) => TextSpan(
            text:
                capitalize ? toUserNameOrYou().capitalize() : toUserNameOrYou(),
            style: TextStyle(color: toPlayer().color),
          );

      TextSpan fromUserNameOrYouTextSpan({bool capitalize = false}) => TextSpan(
            text: capitalize
                ? fromUserNameOrYou().capitalize()
                : fromUserNameOrYou(),
            style: TextStyle(color: fromPlayer().color),
          );

      switch (transaction.type) {
        case TransactionType.fromBank:
          return [
            toUserNameOrYouTextSpan(capitalize: true),
            TextSpan(text: ' received $amount from the bank.')
          ];
        case TransactionType.toBank:
          return [
            fromUserNameOrYouTextSpan(capitalize: true),
            TextSpan(text: ' payed $amount to the bank.')
          ];
        case TransactionType.toPlayer:
          return [
            fromUserNameOrYouTextSpan(capitalize: true),
            const TextSpan(text: ' payed '),
            toUserNameOrYouTextSpan(capitalize: false),
            TextSpan(text: ' $amount.'),
          ];
        case TransactionType.toFreeParking:
          return [
            fromUserNameOrYouTextSpan(capitalize: true),
            TextSpan(text: ' payed $amount to free parking.'),
          ];
        case TransactionType.fromFreeParking:
          return [
            toUserNameOrYouTextSpan(capitalize: true),
            TextSpan(text: ' received the free parking money ($amount).'),
          ];
        case TransactionType.fromSalary:
          final involvedInTransaction = transaction.fromUserId == user.id ||
              transaction.toUserId == user.id;
          final yourOrHis = involvedInTransaction ? 'your' : 'his';
          return [
            toUserNameOrYouTextSpan(capitalize: true),
            TextSpan(text: ' received $yourOrHis salary ($amount).'),
          ];
      }
    }

    IconData getIcon() {
      switch (transaction.type) {
        case TransactionType.fromBank:
        case TransactionType.toBank:
          return FontAwesomeIcons.solidBuilding;
        case TransactionType.toPlayer:
          return FontAwesomeIcons.userFriends;
        case TransactionType.toFreeParking:
        case TransactionType.fromFreeParking:
          return FontAwesomeIcons.carAlt;
        case TransactionType.fromSalary:
          return Icons.work_rounded;
      }
    }

    return Card(
      shape: transactionConcernsMe
          ? RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.withOpacity(0.8), width: 1),
              borderRadius: borderRadius,
            )
          : null,
      child: ListTile(
        title: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: Center(
                child: FaIcon(
                  getIcon(),
                  size: getIcon().fontPackage == 'font_awesome_flutter'
                      ? 17.0
                      : 19.0,
                  color: context.isDarkMode ? Colors.white : Colors.black45,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        fontWeight: transactionConcernsMe
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                  children: getTextSpans(),
                ),
              ),
            ),
          ],
        ),
        trailing: Text(
          transaction.timestamp.format('Hms'),
          style: TextStyle(
            color: context.isDarkMode
                ? Colors.white.withOpacity(0.6)
                : Colors.black54,
          ),
        ),
      ),
    );
  }
}
