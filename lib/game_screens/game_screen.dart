import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:user_repository/user_repository.dart';

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
            onPressed: () => context.userRepository().leaveGame(),
          )
        ],
      ),
      child: EasyStreamBuilder<Game?>(
        stream: context.userRepository().streamGame(user.currentGameId!),
        loadingIndicator: const Center(child: CircularProgressIndicator()),
        dataBuilder: (context, game) {
          //debugPrint('GAME STREAM BUILDER REBUILDS');
          //debugPrint(game.toString());

          if (game == null) {
            context.userRepository().leaveGame();
            throw ('User was disconnected from any game, because the current one does not exist anymore.');
          } else {
            return ListView(
              children: [
                const SizedBox(height: 15),
                _MyBalanceText(game: game, user: user),
                const SizedBox(height: 20),
                _OtherPlayersBalance(game: game, user: user),
                const SizedBox(height: 20),
                _NewTransactionForm(game: game, user: user),
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatBalance(myBalance),
          style: const TextStyle(fontSize: 25),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 3),
          child: Icon(
            Icons.attach_money_rounded,
            size: 27,
          ),
        ),
      ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.people_rounded,
              color: Colors.black54,
            ),
            SizedBox(width: 5),
            Text(
              'Other Players:',
              style: TextStyle(fontSize: 17),
            ),
          ],
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatBalance(player.balance),
                              style: const TextStyle(fontSize: 17),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 1),
                              child: Icon(
                                Icons.attach_money_rounded,
                                color: Colors.black87,
                                size: 20,
                              ),
                            ),
                          ],
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
            fromUserId: user.id,
            toUserId: player.value!.userId,
            amount: amount.value);

        player.value = null;
        amountController.clear();
        amount.value = 0;
      }
    }

    bool isFormNotEmpty() => player.value != null && amount.value > 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            FaIcon(
              FontAwesomeIcons.moneyCheckAlt,
              size: 17,
              color: Colors.black54,
            ),
            SizedBox(width: 5),
            Text(
              'New Transaction:',
              style: TextStyle(fontSize: 17),
            ),
          ],
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
              FilteringTextInputFormatter.digitsOnly,
              _ThousandsSeparatorInputFormatter()
            ],
            validator: (v) => int.parse(v!.replaceAll('.', '')) > myBalance
                ? "You don't have enough money!"
                : null,
            onChanged: (v) =>
                amount.value = v.isBlank ? 0 : int.parse(v.replaceAll('.', '')),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: isFormNotEmpty() ? submitForm : null,
          child: const IconText(
            text: 'Send money',
            icon: FontAwesomeIcons.solidPaperPlane,
            iconSize: 16,
          ),
        )
      ],
    );
  }
}

// #################### Formatters ###################

String _formatBalance(int balance) {
  final chars = balance.toString().split('');

  var newString = '';
  for (var i = chars.length - 1; i >= 0; i--) {
    if ((chars.length - 1 - i) % 3 == 0 && i != chars.length - 1) {
      newString = '.$newString';
    }
    newString = chars[i] + newString;
  }

  return newString;
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = '.';

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Short-circuit if the new value is empty
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Handle "deletion" of separator character
    final oldValueText = oldValue.text.replaceAll(separator, '');
    var newValueText = newValue.text.replaceAll(separator, '');

    if (oldValue.text.endsWith(separator) &&
        oldValue.text.length == newValue.text.length + 1) {
      newValueText = newValueText.substring(0, newValueText.length - 1);
    }

    // Only process if the old value and new value are different
    if (oldValueText != newValueText) {
      final selectionIndex =
          newValue.text.length - newValue.selection.extentOffset;
      final chars = newValueText.split('');

      var newString = '';
      for (var i = chars.length - 1; i >= 0; i--) {
        if ((chars.length - 1 - i) % 3 == 0 && i != chars.length - 1) {
          newString = separator + newString;
        }
        newString = chars[i] + newString;
      }

      return TextEditingValue(
        text: newString.toString(),
        selection: TextSelection.collapsed(
          offset: newString.length - selectionIndex,
        ),
      );
    }

    // If the new value and old value are the same, just return as-is
    return newValue;
  }
}
