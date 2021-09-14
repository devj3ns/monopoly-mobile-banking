import 'package:banking_repository/banking_repository.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:monopoly_banking/shared_widgets.dart';

import '../../../../app/cubit/app_cubit.dart';

extension ShowTransactionModalBottomSheet on BuildContext {
  /// Shows the given [TransactionForm].
  void showTransactionModalBottomSheet(Widget transactionModalBottomSheet) {
    showCupertinoModalBottomSheet<Widget>(
      context: this,
      builder: (_) => RepositoryProvider.value(
          value: read<BankingRepository>(), child: transactionModalBottomSheet),
    );
  }
}

/// A modal bottom sheet for transactions.
///
/// Use context.show(TransactionModalBottomSheet(...)) to open it.
class TransactionForm extends HookWidget {
  const TransactionForm({
    Key? key,
    required this.game,
    required this.transactionType,
    this.toUserId,
    this.showConfetti,
  }) : super(key: key);

  final Game game;
  final TransactionType transactionType;
  final String? toUserId;
  final VoidCallback? showConfetti;

  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppCubit>().state.user;
    final myMoneyBalance = game.getPlayer(user.id).balance;

    final amountController = useTextEditingController();
    final amount = useState(0);

    final checkIfEnoughMoney = transactionType == TransactionType.toBank ||
        transactionType == TransactionType.toFreeParking ||
        transactionType == TransactionType.toPlayer;

    final showBankruptWarning = amount.value == myMoneyBalance &&
        (transactionType == TransactionType.toBank ||
            transactionType == TransactionType.toPlayer ||
            transactionType == TransactionType.toFreeParking);

    final askForAmount = transactionType != TransactionType.fromFreeParking &&
        transactionType != TransactionType.fromSalary;

    String getTitle() {
      switch (transactionType) {
        case TransactionType.fromBank:
          return 'Receive from bank';
        case TransactionType.toBank:
          return 'Pay bank';
        case TransactionType.toPlayer:
          assert(toUserId != null);
          return 'Pay ${game.getPlayer(toUserId!).name}';
        case TransactionType.toFreeParking:
          return 'Pay to free parking';
        case TransactionType.fromFreeParking:
          return 'Receive free parking money';
        case TransactionType.fromSalary:
          return 'Receive salary';
      }
    }

    String getConfirmationText() {
      assert(!askForAmount);

      switch (transactionType) {
        case TransactionType.fromSalary:
          return "Has your token passed or landed on the 'GO' field?";
        case TransactionType.fromFreeParking:
          return "Has your token landed on the 'Free Parking' field?";
        default:
          throw ('getConfirmationText() was called even though askForAmount is false!');
      }
    }

    void submitForm() {
      if (askForAmount ? _formKey.currentState!.validate() : true) {
        context.read<BankingRepository>().makeTransaction(
              game: game,
              transactionType: transactionType,
              amount: amount.value,
              toUserId: toUserId,
            );

        amountController.clear();
        amount.value = 0;

        context.popPage();

        showConfetti?.call();
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
                getTitle(),
                style: const TextStyle(fontSize: 20),
              ),
              askForAmount
                  ? Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: MoneyBalanceFormField(
                            controller: amountController,
                            autofocus: true,
                            onChanged: (value) => amount.value = value,
                            onEditingComplete: submitForm,
                            hintText: 'Amount',
                            validator: (value) {
                              return value <= 0
                                  ? 'Please enter a number!'
                                  : checkIfEnoughMoney
                                      ? value > myMoneyBalance
                                          ? "You don't have enough money!"
                                          : null
                                      : null;
                            },
                          ),
                        ),
                        //
                        if (showBankruptWarning)
                          const Padding(
                            padding: EdgeInsets.only(top: 7.0),
                            child: Text(
                              'You will be bankrupt after this transaction!',
                              style: TextStyle(color: Colors.red),
                            ),
                          )
                      ],
                    )
                  : Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(getConfirmationText()),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: submitForm,
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
