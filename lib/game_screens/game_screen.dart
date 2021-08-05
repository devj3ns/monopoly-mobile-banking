import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

import 'package:banking_repository/banking_repository.dart';

import '../extensions.dart';
import '../shared_widgets.dart';

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
            tooltip: 'Leave',
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
                _NewTransactionForm(game: game, user: user),
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
  const _MyBalanceText({Key? key, required this.game, required this.user})
      : super(key: key);
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
  const _OtherPlayersBalance({Key? key, required this.game, required this.user})
      : super(key: key);
  final Game game;
  final User user;

  @override
  Widget build(BuildContext context) {
    final otherPlayers = game.otherPlayers(user.id)..sort((a, b) => a.balance);

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
                children: otherPlayers.map(
                  (player) {
                    return Card(
                      child: ListTile(
                        title: Text(player.name),
                        trailing: Text(
                          context.formatBalance(player.balance),
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
      ],
    );
  }
}

class _NewTransactionForm extends HookWidget {
  const _NewTransactionForm({Key? key, required this.game, required this.user})
      : super(key: key);
  final Game game;
  final User user;

  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final otherUsers = game.otherPlayers(user.id);
    final myBalance = game.getPlayer(user.id).balance;

    final player = useState<Player?>(null);
    final amountController = useTextEditingController();
    final amount = useState(0);

    void submitForm() {
      if (_formKey.currentState!.validate()) {
        game.makeTransaction(
            fromUser: user,
            toUser: User(id: player.value!.userId, name: player.value!.name),
            amount: amount.value);

        player.value = null;
        amountController.clear();
        amount.value = 0;
      }
    }

    bool isFormNotEmpty() => player.value != null && amount.value > 0;

    return Column(
      children: [
        const IconText(
          icon: FaIcon(
            FontAwesomeIcons.exchangeAlt,
            size: 17,
            color: Colors.black54,
          ),
          text: Text(
            'New Transaction:',
            style: TextStyle(fontSize: 17),
          ),
          iconAfterText: false,
        ),
        DropdownButtonFormField<Player>(
          value: player.value,
          items: otherUsers
              .map(
                (player) => DropdownMenuItem(
                  child: Text(player.name),
                  value: player,
                ),
              )
              .toList(),
          decoration: const InputDecoration(
            labelText: 'Player',
          ),
          onChanged: (user) => player.value = user ?? player.value,
        ),
        Form(
          key: _formKey,
          child: TextFormField(
            decoration: const InputDecoration(hintText: 'Amount'),
            keyboardType: TextInputType.number,
            controller: amountController,
            inputFormatters: [
              CurrencyTextInputFormatter(
                locale: Localizations.localeOf(context).toLanguageTag(),
                symbol: '\$',
                decimalDigits: 0,
              )
            ],
            validator: (value) {
              final balance =
                  int.parse(value!.replaceAll(RegExp(r'[^0-9]+'), ''));

              return balance > myBalance
                  ? "You don't have enough money!"
                  : null;
            },
            onChanged: (value) => amount.value = value.isBlank
                ? 0
                : int.parse(value.replaceAll(RegExp(r'[^0-9]+'), '')),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: isFormNotEmpty() ? submitForm : null,
          child: const IconText(
            text: Text('Send money'),
            icon: FaIcon(
              FontAwesomeIcons.solidPaperPlane,
              size: 16,
            ),
          ),
        )
      ],
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
    final transactions = game.transactions.asList().toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

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
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];

                    final text = transaction.fromUser.id == user.id
                        ? 'You sent ${context.formatBalance(transaction.amount)} to ${transaction.toUser.name}.'
                        : transaction.toUser.id == user.id
                            ? 'You got ${context.formatBalance(transaction.amount)} from ${transaction.fromUser.name}.'
                            : '${transaction.fromUser.name} sent ${context.formatBalance(transaction.amount)} to ${transaction.toUser.name}.';

                    return Card(
                      child: ListTile(
                        title: Text(text),
                        trailing: Text(
                          transaction.timestamp.format('Hms'),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
