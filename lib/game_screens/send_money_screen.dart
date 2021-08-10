import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';
import 'package:fleasy/fleasy.dart';

import 'package:banking_repository/banking_repository.dart';

import '../shared_widgets.dart';

class SendMoneyScreen extends StatelessWidget {
  const SendMoneyScreen({
    Key? key,
    required this.game,
    required this.user,
    required this.toPlayer,
  }) : super(key: key);

  final Game game;
  final User user;
  final Player toPlayer;

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
      appBar: AppBar(
        title: Text('Send money to ${toPlayer.name}'),
      ),
      child: _NewTransactionForm(game: game, user: user, toPlayer: toPlayer),
    );
  }
}

class _NewTransactionForm extends HookWidget {
  const _NewTransactionForm({
    Key? key,
    required this.game,
    required this.user,
    required this.toPlayer,
  }) : super(key: key);

  final Game game;
  final User user;
  final Player toPlayer;

  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final myBalance = game.getPlayer(user.id).balance;

    final amountController = useTextEditingController();
    final amount = useState(0);

    void submitForm() {
      if (_formKey.currentState!.validate()) {
        game.makeTransaction(
            fromUser: user,
            toUser: User(id: toPlayer.userId, name: toPlayer.name),
            amount: amount.value);

        amountController.clear();
        amount.value = 0;

        context.popPage();
      }
    }

    return Column(
      children: [
        Form(
          key: _formKey,
          child: BalanceFormField(
            controller: amountController,
            myBalance: myBalance,
            onChanged: (balance) => amount.value = balance,
            onSubmit: submitForm,
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: amount.value > 0 ? submitForm : null,
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
