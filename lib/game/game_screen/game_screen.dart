import 'package:intl/intl.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:banking_repository/banking_repository.dart';
import 'package:monopoly_banking/app/cubit/app_cubit.dart';
import 'package:user_repository/user_repository.dart';

import '../../extensions.dart';
import '../../shared_widgets.dart';
import 'transaction_modal_bottom_sheet.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppCubit>().state.user;
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
      body: EasyStreamBuilder<Game?>(
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
                _AnimatedBalanceText(
                  balance: game.getPlayer(user.id).balance,
                  textStyle: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w600),
                ),
                const Divider(height: 30),
                _OtherPlayersBalance(game: game),
                const Divider(height: 30),
                _BankButtons(game: game),
                const Divider(height: 30),
                _TransactionHistory(game: game),
              ],
            );
          }
        },
      ),
    );
  }
}

class _AnimatedBalanceText extends StatelessWidget {
  const _AnimatedBalanceText({
    Key? key,
    required this.balance,
    this.textStyle,
  }) : super(key: key);

  final int balance;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          child: child,
          scale: CurveTween(curve: Curves.easeInOut).animate(animation),
        );
      },
      child: Text(
        context.formatBalance(balance),
        key: ValueKey(context.formatBalance(balance)),
        style: textStyle,
      ),
    );
  }
}

class _OtherPlayersBalance extends StatelessWidget {
  const _OtherPlayersBalance({
    Key? key,
    required this.game,
  }) : super(key: key);

  final Game game;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppCubit>().state.user;
    final otherPlayers = game.otherPlayers(user.id);

    return Column(
      children: [
        const IconText(
          icon: Icon(
            Icons.people_rounded,
            color: Colors.black54,
          ),
          text: Text(
            'Other Players',
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
  }) : super(key: key);

  final Game game;
  final Player player;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppCubit>().state.user;

    return Card(
      child: Tooltip(
        message: 'Send money to ${player.name}',
        child: ListTile(
          title: Text(player.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AnimatedBalanceText(
                balance: player.balance,
                textStyle: const TextStyle(fontSize: 17),
              ),
              const SizedBox(width: 15),
              const Icon(
                FontAwesomeIcons.handHoldingUsd,
                size: 19,
              ),
            ],
          ),
          onTap: () => showCupertinoModalBottomSheet<Widget>(
            context: context,
            builder: (context) => TransactionModalBottomSheet(
              game: game,
              toUser: User(id: player.userId, name: player.name),
              fromUser: user,
            ),
          ),
        ),
      ),
    );
  }
}

class _BankButtons extends StatelessWidget {
  const _BankButtons({
    Key? key,
    required this.game,
  }) : super(key: key);

  final Game game;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppCubit>().state.user;

    return Column(
      children: [
        const IconText(
          icon: FaIcon(
            FontAwesomeIcons.solidBuilding,
            size: 17,
            color: Colors.black54,
          ),
          text: Text(
            'Bank',
            style: TextStyle(fontSize: 17),
          ),
          iconAfterText: false,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const IconText(
                text: Text('Pay'),
                gap: 8,
                icon: FaIcon(
                  FontAwesomeIcons.handHoldingUsd,
                  size: 16,
                ),
              ),
              onPressed: () => showCupertinoModalBottomSheet<Widget>(
                context: context,
                builder: (context) => TransactionModalBottomSheet(
                  game: game,
                  toUser: null,
                  fromUser: user,
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              child: const IconText(
                text: Text('Get'),
                gap: 8,
                icon: FaIcon(
                  Icons.payments_outlined,
                  size: 19,
                ),
              ),
              onPressed: () => showCupertinoModalBottomSheet<Widget>(
                context: context,
                builder: (context) => TransactionModalBottomSheet(
                  game: game,
                  toUser: user,
                  fromUser: null,
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
    final transactions = game.transactions.asList();

    return Expanded(
      child: Column(
        children: [
          const IconText(
            icon: FaIcon(
              FontAwesomeIcons.history,
              size: 17,
              color: Colors.black54,
            ),
            text: Text(
              'Transaction History',
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
                    itemBuilder: (context, index) =>
                        _TransactionCard(transaction: transactions[index]),
                  ),
                ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppCubit>().state.user;

    String getText() {
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
