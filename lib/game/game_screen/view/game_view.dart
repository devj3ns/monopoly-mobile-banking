import 'dart:math';

import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:confetti/confetti.dart';

import 'package:banking_repository/banking_repository.dart';

import '../../../app/cubit/app_cubit.dart';
import '../../../extensions.dart';
import '../../../shared_widgets.dart';
import 'animated_balance_text.dart';
import 'transaction_modal_bottom_sheet.dart';

class GameView extends StatelessWidget {
  const GameView({Key? key, required this.game}) : super(key: key);
  final Game game;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppCubit>().state.user;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            const SizedBox(height: 15),
            AnimatedBalanceText(
              balance: game.getPlayer(user.id).balance,
              textStyle:
                  const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
            ),
            const Divider(height: 30),
            _PayArea(game: game),
            const Divider(height: 30),
            _ReceiveArea(game: game),
            const Divider(height: 30),
            _TransactionHistory(game: game),
          ],
        ),
        game.winner != null
            ? _SomeOneWonOverlay(winner: game.winner!)
            : game.isBankrupt(user.id)
                ? const _YouAreBankruptOverlay()
                : const SizedBox(),
      ],
    );
  }
}

class _YouAreBankruptOverlay extends StatelessWidget {
  const _YouAreBankruptOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
      child: Center(
        child: Text(
          'You are bankrupt!',
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
    );
  }
}

class _SomeOneWonOverlay extends StatefulWidget {
  const _SomeOneWonOverlay({Key? key, required this.winner}) : super(key: key);
  final Player winner;

  @override
  _SomeOneWonOverlayState createState() => _SomeOneWonOverlayState();
}

class _SomeOneWonOverlayState extends State<_SomeOneWonOverlay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3))..play();

    super.initState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppCubit>().state.user;

    return ConfettiWidget(
      confettiController: _confettiController,
      blastDirection: pi / 2,
      blastDirectionality: BlastDirectionality.explosive,
      particleDrag: 0.05,
      emissionFrequency: 0.05,
      numberOfParticles: 25,
      gravity: 0.05,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
        child: Center(
          child: Text(
            '${widget.winner.userId == user.id ? 'You' : widget.winner.name} won the game!',
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
      ),
    );
  }
}

class _PayArea extends StatelessWidget {
  const _PayArea({
    Key? key,
    required this.game,
  }) : super(key: key);

  final Game game;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppCubit>().state.user;
    final otherPlayers = game.otherNonBankruptPlayers(user.id);

    return Column(
      children: [
        const IconText(
          icon: FaIcon(
            FontAwesomeIcons.handHoldingUsd,
            size: 14,
          ),
          gap: 7,
          text: Text(
            'Pay',
            style: TextStyle(fontSize: 17),
          ),
        ),
        const SizedBox(height: 5),
        otherPlayers.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('There are no other players yet.'),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: otherPlayers
                    .map(
                      (player) => _PlayerCard(
                        game: game,
                        player: player,
                      ),
                    )
                    .toList(),
              ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 1,
              child: Card(
                child: ListTile(
                  leading: const IconText(
                    icon: FaIcon(
                      FontAwesomeIcons.solidBuilding,
                      size: 16,
                    ),
                    gap: 10,
                    text: Text(
                      'Bank',
                      style: TextStyle(fontSize: 16),
                    ),
                    iconAfterText: false,
                  ),
                  onTap: () => context.showTransactionModalBottomSheet(
                    TransactionForm(
                      game: game,
                      transactionType: TransactionType.toBank,
                    ),
                  ),
                ),
              ),
            ),
            if (game.enableFreeParkingMoney)
              Expanded(
                flex: 2,
                child: Card(
                  child: ListTile(
                    leading: const IconText(
                      icon: FaIcon(
                        FontAwesomeIcons.carAlt,
                        size: 16,
                      ),
                      gap: 10,
                      text: Text(
                        'Free Parking',
                        style: TextStyle(fontSize: 16),
                      ),
                      iconAfterText: false,
                    ),
                    trailing: AnimatedBalanceText(
                      balance: game.freeParkingMoney,
                      textStyle: const TextStyle(
                        fontSize: 17,
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () => context.showTransactionModalBottomSheet(
                      TransactionForm(
                        game: game,
                        transactionType: TransactionType.toFreeParking,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        )
      ],
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    Key? key,
    required this.game,
    required this.player,
  }) : super(key: key);

  final Game game;
  final Player player;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: IconText(
          icon: const FaIcon(
            FontAwesomeIcons.solidUser,
            size: 17,
          ),
          gap: 10,
          text: Text(
            player.name,
            style: const TextStyle(fontSize: 16),
          ),
          iconAfterText: false,
          mainAxisAlignment: MainAxisAlignment.start,
        ),
        trailing: AnimatedBalanceText(
          balance: player.balance,
          textStyle: const TextStyle(
            fontSize: 17,
            color: Colors.grey,
          ),
        ),
        onTap: () => context.showTransactionModalBottomSheet(
          TransactionForm(
            game: game,
            transactionType: TransactionType.toPlayer,
            toUserId: player.userId,
          ),
        ),
      ),
    );
  }
}

class _ReceiveArea extends StatelessWidget {
  const _ReceiveArea({
    Key? key,
    required this.game,
  }) : super(key: key);

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const IconText(
          icon: FaIcon(
            Icons.payments_outlined,
            size: 17,
          ),
          gap: 7,
          text: Text(
            'Receive',
            style: TextStyle(fontSize: 17),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Card(
                child: ListTile(
                  leading: const IconText(
                    icon: FaIcon(
                      FontAwesomeIcons.solidBuilding,
                      size: 16,
                    ),
                    gap: 10,
                    text: Text(
                      'Bank',
                      style: TextStyle(fontSize: 16),
                    ),
                    iconAfterText: false,
                  ),
                  onTap: () => context.showTransactionModalBottomSheet(
                    TransactionForm(
                      game: game,
                      transactionType: TransactionType.fromBank,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: ListTile(
                  leading: const IconText(
                    icon: FaIcon(
                      Icons.work_rounded,
                      size: 18,
                    ),
                    gap: 10,
                    text: Text(
                      'Salary',
                      style: TextStyle(fontSize: 16),
                    ),
                    iconAfterText: false,
                  ),
                  onTap: () => context.showTransactionModalBottomSheet(
                    TransactionForm(
                      game: game,
                      transactionType: TransactionType.fromSalary,
                    ),
                  ),
                ),
              ),
            ),
            if (game.enableFreeParkingMoney)
              Expanded(
                child: Card(
                  child: ListTile(
                    leading: const IconText(
                      icon: FaIcon(
                        FontAwesomeIcons.carAlt,
                        size: 18,
                      ),
                      gap: 10,
                      text: Text(
                        'Free Parking',
                        style: TextStyle(fontSize: 16),
                      ),
                      iconAfterText: false,
                    ),
                    onTap: game.freeParkingMoney <= 0
                        ? () => context.showInfoFlashbar(
                              message:
                                  'Sorry, at the moment there is no free parking money.',
                              duration: 2,
                            )
                        : () => context.showTransactionModalBottomSheet(
                              TransactionForm(
                                game: game,
                                transactionType:
                                    TransactionType.fromFreeParking,
                              ),
                            ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TransactionHistory extends StatelessWidget {
  const _TransactionHistory({
    Key? key,
    required this.game,
  }) : super(key: key);

  final Game game;

  @override
  Widget build(BuildContext context) {
    final transactions = game.transactionHistory.asList();

    return Column(
      children: [
        const IconText(
          icon: FaIcon(
            Icons.history_rounded,
            size: 19,
          ),
          gap: 7,
          text: Text(
            'Transaction History',
            style: TextStyle(fontSize: 17),
          ),
        ),
        const SizedBox(height: 6),
        transactions.isEmpty
            ? const Center(
                child: Text('There are no transactions yet.'),
              )
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                shrinkWrap: true,
                itemBuilder: (context, index) => _TransactionCard(
                    transaction: transactions[index], game: game),
              ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    Key? key,
    required this.transaction,
    required this.game,
  }) : super(key: key);

  final Transaction transaction;
  final Game game;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppCubit>().state.user;

    String getText() {
      //todo: improve this code (make more readable and easier to understand):
      final myTransaction =
          transaction.fromUserId == user.id || transaction.toUserId == user.id;
      final isFromMe = transaction.fromUserId == user.id;

      final fromUserName = transaction.fromUserId != null
          ? game.getPlayer(transaction.fromUserId!).name
          : null;
      final toUserName = transaction.toUserId != null
          ? game.getPlayer(transaction.toUserId!).name
          : null;
      final amount = context.formatBalance(transaction.amount);

      switch (transaction.type) {
        case TransactionType.fromBank:
          return myTransaction
              ? 'You received $amount from the bank.'
              : '$toUserName received $amount from the bank.';
        case TransactionType.toBank:
          return myTransaction
              ? 'You payed $amount to the bank.'
              : '$fromUserName payed $amount to the bank.';
        case TransactionType.toPlayer:
          return isFromMe
              ? myTransaction
                  ? 'You payed $toUserName $amount.'
                  : '$fromUserName payed $toUserName $amount.'
              : myTransaction
                  ? '$toUserName payed you $amount.'
                  : '$fromUserName payed $toUserName $amount.';
        case TransactionType.toFreeParking:
          return myTransaction
              ? 'You payed $amount to free parking.'
              : '$fromUserName payed $amount to free parking.';
        case TransactionType.fromFreeParking:
          return myTransaction
              ? 'You received the free parking money ($amount).'
              : '$toUserName received the free parking money ($amount).';
        case TransactionType.fromSalary:
          return myTransaction
              ? 'You received your salary ($amount).'
              : '$toUserName received his salary ($amount).';
      }
    }

    return Card(
      child: ListTile(
        title: Text(getText()),
        trailing: Text(
          transaction.timestamp.format('Hms'),
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
