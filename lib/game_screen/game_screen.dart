import 'package:flutter/material.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:flutter/services.dart';
import 'package:user_repository/user_repository.dart';

import '../extensions.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  Widget build(BuildContext context) {
    assert(user.currentGameId != null);

    return StreamBuilder<Game?>(
      stream: context.userRepository().streamGame(user.currentGameId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error?.toString() ?? 'ERROR');
        }
        final game = snapshot.data;

        //debugPrint('GAME STREAM REBUILDS');
        //debugPrint(game.toString());

        if (game == null) {
          debugPrint(
              '[WARNING] User was disconnected from any game, because it does not exist anymore.');
          context.userRepository().leaveGame();
        }
        assert(game != null);

        return Scaffold(
          appBar: AppBar(
            title: Text(user.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Disconnect',
                onPressed: () => context.userRepository().leaveGame(),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _MyBalanceText(game: game!, user: user),
                  const Divider(height: 25),
                  _OtherPlayersBalance(game: game, user: user),
                  const Divider(height: 25),
                  _NewTransactionForm(game: game, user: user),
                ],
              ),
            ),
          ),
        );
      },
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
      _formatBalance(myBalance),
      style: const TextStyle(fontSize: 22),
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
    final otherPlayers = game.otherPlayers(user.id);

    return Column(
      children: [
        const Text('Other Players:'),
        otherPlayers.isEmpty
            ? const Text('There are not other players yet.')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: otherPlayers.map(
                  (player) {
                    return Card(
                      child: ListTile(
                        title: Text(player.name),
                        trailing: Text(_formatBalance(player.balance)),
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
        const Text('New transaction:'),
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
            labelText: 'Select Player',
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
          child: const Text('Transfer'),
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

  return '$newString €';
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
