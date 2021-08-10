import 'package:flutter/material.dart';
import 'package:fleasy/fleasy.dart';

import 'package:banking_repository/banking_repository.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../shared_widgets.dart';

class BankScreen extends StatelessWidget {
  const BankScreen({Key? key, required this.game, required this.user})
      : super(key: key);
  final Game game;
  final User user;

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
      appBar: AppBar(
        title: const Text('Bank'),
      ),
      child: Column(
        children: [
          _GetMoneyForm(game: game, user: user),
          const SizedBox(height: 25),
          _PayMoneyForm(game: game, user: user),
        ],
      ),
    );
  }
}

class _GetMoneyForm extends HookWidget {
  const _GetMoneyForm({Key? key, required this.game, required this.user})
      : super(key: key);
  final Game game;
  final User user;

  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final myBalance = game.getPlayer(user.id).balance;
    final amountController = useTextEditingController();
    final amount = useState(0);

    void submitForm() {
      if (_formKey.currentState!.validate()) {
        game.getMoneyFromBank(user: user, amount: amount.value);

        amountController.clear();
        amount.value = 0;

        context.popPage();
      }
    }

    return Column(
      children: [
        const Text('Get money:'),
        Form(
          key: _formKey,
          child: BalanceFormField(
            controller: amountController,
            myBalance: myBalance,
            onChanged: (balance) => amount.value = balance,
            onSubmit: submitForm,
          ),
        ),
        ElevatedButton(
          onPressed: submitForm,
          child: const Text('Get'),
        ),
      ],
    );
  }
}

class _PayMoneyForm extends HookWidget {
  const _PayMoneyForm({Key? key, required this.game, required this.user})
      : super(key: key);
  final Game game;
  final User user;

  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final myBalance = game.getPlayer(user.id).balance;
    final amountController = useTextEditingController();
    final amount = useState(0);

    void submitForm() {
      if (_formKey.currentState!.validate()) {
        game.sendMoneyToBank(user: user, amount: amount.value);

        amountController.clear();
        amount.value = 0;

        context.popPage();
      }
    }

    return Column(
      children: [
        const Text('Pay money:'),
        Form(
          key: _formKey,
          child: BalanceFormField(
            controller: amountController,
            myBalance: myBalance,
            onChanged: (balance) => amount.value = balance,
            onSubmit: submitForm,
          ),
        ),
        ElevatedButton(
          onPressed: submitForm,
          child: const Text('Pay'),
        ),
      ],
    );
  }
}
