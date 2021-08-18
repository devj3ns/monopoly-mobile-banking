import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fleasy/fleasy.dart';

import '../../../shared_widgets.dart';
import '../cubit/create_game_cubit.dart';

class CreateGameForm extends StatelessWidget {
  const CreateGameForm({Key? key}) : super(key: key);

  static final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    void submitForm() async {
      if (formKey.currentState!.validate()) {
        await context.read<CreateGameCubit>().onFormSubmitted();
        context.popPage();
      }
    }

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          SizedBox(height: context.screenHeight * 0.3),
          const _StartingCapitalInput(),
          const _SalaryInput(),
          const _FreeParkingSwitch(),
          _SubmitButton(submitForm),
        ],
      ),
    );
  }
}

class _StartingCapitalInput extends StatelessWidget {
  const _StartingCapitalInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BalanceFormField(
      labelText: 'Starting Balance',
      initialValue: context.read<CreateGameCubit>().state.startingCapital,
      onChanged: context.read<CreateGameCubit>().onStartingCapitalChanged,
    );
  }
}

class _SalaryInput extends StatelessWidget {
  const _SalaryInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BalanceFormField(
      labelText: 'Salary',
      initialValue: context.read<CreateGameCubit>().state.salary,
      onChanged: context.read<CreateGameCubit>().onSalaryChanged,
    );
  }
}

class _FreeParkingSwitch extends HookWidget {
  const _FreeParkingSwitch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SelectableText('Free Parking Money'),
        Switch(
          value: context.watch<CreateGameCubit>().state.enableFreeParkingMoney,
          onChanged:
              context.read<CreateGameCubit>().onEnableFreeParkingMoneyChanged,
        ),
      ],
    );
  }
}

class _BalanceFormField extends StatelessWidget {
  const _BalanceFormField({
    Key? key,
    required this.labelText,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  final String labelText;
  final Function(int) onChanged;
  final int initialValue;

  @override
  Widget build(BuildContext context) {
    final inputFormatter = CurrencyTextInputFormatter(
      locale: Localizations.localeOf(context).toLanguageTag(),
      symbol: '\$',
      decimalDigits: 0,
    );

    return TextFormField(
      initialValue: inputFormatter.format(initialValue.toString()),
      decoration: InputDecoration(labelText: labelText),
      keyboardType: TextInputType.number,
      inputFormatters: [inputFormatter],
      validator: (value) {
        final balance = value.isBlank
            ? 0
            : int.parse(value!.replaceAll(RegExp(r'[^0-9]+'), ''));

        if (balance <= 0) return 'Please enter a number!';
      },
      onChanged: (value) => onChanged(
        value.toString().isBlank
            ? 0
            : int.parse(value.replaceAll(RegExp(r'[^0-9]+'), '')),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton(this.submitForm);
  final VoidCallback submitForm;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: Insets.m),
        child: BlocBuilder<CreateGameCubit, CreateGameState>(
          buildWhen: (previous, current) =>
              previous.isSubmitting != current.isSubmitting,
          builder: (context, state) {
            return state.isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    child: const IconText(
                      text: Text('Create & join'),
                      icon: Icon(Icons.login_rounded),
                    ),
                    onPressed: submitForm,
                  );
          },
        ),
      ),
    );
  }
}
