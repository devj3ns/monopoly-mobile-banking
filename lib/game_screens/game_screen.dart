import 'package:intl/intl.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:banking_repository/banking_repository.dart';
import 'package:monopoly_banking/game_screens/bank_screen.dart';

import '../extensions.dart';
import '../shared_widgets.dart';
import 'bank_screen.dart';
import 'send_money_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  Widget build(BuildContext context) {
    assert(user.currentGameId != null);

    return BasicScaffold(
      appBar: AppBar(
        title: const Text('Monopoly Banking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Leave game',
            onPressed: () => context.bankingRepository().leaveGame(),
          )
        ],
      ),
      child: EasyStreamBuilder<Game?>(
        stream: context.bankingRepository().streamGame(user.currentGameId!),
        loadingIndicator: const Center(child: CircularProgressIndicator()),
        dataBuilder: (context, game) {
          //debugPrint('GAME STREAM BUILDER REBUILDS');
          //debugPrint(game.toString());

          if (game == null) {
            context.bankingRepository().leaveGame();
            throw ('User was disconnected from any game, because the current one does not exist anymore.');
          } else {
            return Column(
              children: [
                const SizedBox(height: 15),
                _MyBalanceText(game: game, user: user),
                const SizedBox(height: 20),
                _OtherPlayersBalance(game: game, user: user),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const IconText(
                    text: Text('Bank'),
                    gap: 8,
                    icon: FaIcon(
                      FontAwesomeIcons.building,
                      size: 16,
                    ),
                  ),
                  onPressed: () =>
                      context.pushPage(BankScreen(game: game, user: user)),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _TransactionHistory(game: game, user: user),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class _MyBalanceText extends StatelessWidget {
  const _MyBalanceText({
    Key? key,
    required this.game,
    required this.user,
  }) : super(key: key);

  final Game game;
  final User user;

  @override
  Widget build(BuildContext context) {
    final myBalance = game.getPlayer(user.id).balance;

    return Text(
      context.formatBalance(myBalance),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 25),
    );
  }
}

class _OtherPlayersBalance extends StatelessWidget {
  const _OtherPlayersBalance({
    Key? key,
    required this.game,
    required this.user,
  }) : super(key: key);

  final Game game;
  final User user;

  @override
  Widget build(BuildContext context) {
    final otherPlayers = game.otherPlayers(user.id);

    return Column(
      children: [
        const IconText(
          icon: Icon(
            Icons.people_rounded,
            color: Colors.black54,
          ),
          text: Text(
            'Other Players:',
            style: TextStyle(fontSize: 17),
          ),
          iconAfterText: false,
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
                        user: user,
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    Key? key,
    required this.game,
    required this.player,
    required this.user,
  }) : super(key: key);

  final Game game;
  final Player player;
  final User user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Tooltip(
        message: 'Send money to ${player.name}',
        child: ListTile(
          title: Text(player.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.formatBalance(player.balance),
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(width: 15),
              const Icon(
                FontAwesomeIcons.paperPlane,
                size: 19,
              ),
            ],
          ),
          onTap: () => context.pushPage(
            SendMoneyScreen(
              game: game,
              user: user,
              toPlayer: player,
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionHistory extends StatelessWidget {
  const _TransactionHistory({
    Key? key,
    required this.game,
    required this.user,
  }) : super(key: key);

  final Game game;
  final User user;

  @override
  Widget build(BuildContext context) {
    final transactions = game.transactions.asList();

    return Column(
      children: [
        const IconText(
          icon: FaIcon(
            FontAwesomeIcons.history,
            size: 17,
            color: Colors.black54,
          ),
          text: Text(
            'Transaction History:',
            style: TextStyle(fontSize: 17),
          ),
          iconAfterText: false,
        ),
        const SizedBox(height: 6),
        transactions.isEmpty
            ? const Center(
                child: Text('There are no transactions yet.'),
              )
            : Flexible(
                child: ListView.builder(
                  itemCount: transactions.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => _TransactionCard(
                    user: user,
                    transaction: transactions[index],
                  ),
                ),
              ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    Key? key,
    required this.user,
    required this.transaction,
  }) : super(key: key);

  final User user;
  final Transaction transaction;

  String getText(BuildContext context) {
    final toName =
        user.id == transaction.toUser?.id ? 'you' : transaction.toUser?.name;
    final fromName = user.id == transaction.fromUser?.id
        ? 'you'
        : transaction.fromUser?.name;
    final amount = context.formatBalance(transaction.amount);

    if (transaction.fromUser == null) {
      return toBeginningOfSentenceCase('$toName got $amount from the bank.')!;
    } else if (transaction.toUser == null) {
      return toBeginningOfSentenceCase('$fromName paid the bank $amount.')!;
    } else {
      return toBeginningOfSentenceCase('$fromName sent $amount to $toName.')!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(getText(context)),
        trailing: Text(
          transaction.timestamp.format('Hms'),
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
