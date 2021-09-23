import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared_widgets.dart';
import '../cubit/create_game_cubit.dart';

class CreateGameForm extends StatelessWidget {
  const CreateGameForm({Key? key}) : super(key: key);

  static final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    void submitForm() {
      if (formKey.currentState!.validate()) {
        context.read<CreateGameCubit>().onFormSubmitted();
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
    return MoneyBalanceFormField(
      labelText: 'Starting Capital',
      initialValue: context.read<CreateGameCubit>().state.startingCapital,
      onChanged: context.read<CreateGameCubit>().onStartingCapitalChanged,
      textInputAction: TextInputAction.next,
      validator: (value) => value <= 0 ? 'Please enter a number.' : null,
    );
  }
}

class _SalaryInput extends StatelessWidget {
  const _SalaryInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MoneyBalanceFormField(
      labelText: 'Salary',
      initialValue: context.read<CreateGameCubit>().state.salary,
      onChanged: context.read<CreateGameCubit>().onSalaryChanged,
      textInputAction: TextInputAction.next,
      validator: (value) => value <= 0 ? 'Please enter a number.' : null,
    );
  }
}

class _FreeParkingSwitch extends StatelessWidget {
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
