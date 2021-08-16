import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:banking_repository/banking_repository.dart';
import 'package:monopoly_banking/app/cubit/app_cubit.dart';
import 'package:user_repository/user_repository.dart';

/// A modal bottom sheet for transactions.
class TransactionModalBottomSheet extends HookWidget {
  const TransactionModalBottomSheet({
    Key? key,
    required this.game,
    this.toUser,
    this.fromUser,
  })  : assert(toUser != null || fromUser != null),
        super(key: key);

  /// The current game.
  final Game game;

  /// The user who should receive the money (if null its the bank).
  final User? toUser;

  /// The user from which the money is taken (if null its the bank).
  final User? fromUser;

  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppCubit>().state.user;
    final myBalance = game.getPlayer(user.id).balance;

    final amountController = useTextEditingController();
    final amount = useState(0);

    void submitForm() {
      if (_formKey.currentState!.validate()) {
        game.makeTransaction(
          fromUser: fromUser,
          toUser: toUser,
          amount: amount.value,
        );

        amountController.clear();
        amount.value = 0;

        context.popPage();
      }
    }

    return Material(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 0),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                toUser == null
                    ? 'Pay bank'
                    : fromUser == null
                        ? 'Get from bank'
                        : 'Pay ${toUser!.name}',
                style: const TextStyle(fontSize: 20),
              ),
              Form(
                key: _formKey,
                child: _BalanceFormField(
                  controller: amountController,
                  myBalance: myBalance,
                  onChanged: (balance) => amount.value = balance,
                  onSubmit: submitForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceFormField extends StatelessWidget {
  const _BalanceFormField({
    Key? key,
    required this.controller,
    required this.myBalance,
    required this.onChanged,
    required this.onSubmit,
  }) : super(key: key);

  final TextEditingController controller;
  final int myBalance;
  final Function(int) onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(hintText: 'Amount'),
      keyboardType: TextInputType.number,
      controller: controller,
      inputFormatters: [
        CurrencyTextInputFormatter(
          locale: Localizations.localeOf(context).toLanguageTag(),
          symbol: '\$',
          decimalDigits: 0,
        )
      ],
      validator: (value) {
        final balance = int.parse(value!.replaceAll(RegExp(r'[^0-9]+'), ''));

        return balance > myBalance ? "You don't have enough money!" : null;
      },
      onChanged: (value) => onChanged(
        value.toString().isBlank
            ? 0
            : int.parse(value.replaceAll(RegExp(r'[^0-9]+'), '')),
      ),
      onEditingComplete: onSubmit,
      autofocus: true,
    );
  }
}
