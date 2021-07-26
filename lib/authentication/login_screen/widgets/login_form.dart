import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fleasy/fleasy.dart';

import '../cubit/login_cubit.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  static final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    void submitForm() {
      if (formKey.currentState!.validate()) {
        context
          ..dismissKeyboard()
          ..read<LoginCubit>().onFormSubmitted();
      }
    }

    return Form(
      key: formKey,
      child: ListView(
        children: [
          const SizedBox(height: Insets.xxl * 2),
          _FirstNameInput(),
          _LoginButton(submitForm),
        ],
      ),
    );
  }
}

class _FirstNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.m),
      child: TextFormField(
        autofillHints: const [AutofillHints.username],
        onChanged: (firstName) =>
            context.read<LoginCubit>().firstNameChanged(firstName.trim()),
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          labelText: 'Vorname',
        ),
        validator: (value) =>
            value.isBlank ? 'Bitte gib deinen Vornamen ein' : null,
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton(this.submitForm);
  final VoidCallback submitForm;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: Insets.m),
        child: BlocBuilder<LoginCubit, LoginState>(
          buildWhen: (previous, current) =>
              previous.isSubmitting != current.isSubmitting,
          builder: (context, state) {
            return state.isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    child: const Text('Einloggen'),
                    onPressed: submitForm,
                  );
          },
        ),
      ),
    );
  }
}
