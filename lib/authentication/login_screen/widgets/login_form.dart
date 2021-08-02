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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: formKey,
        child: ListView(
          children: [
            SizedBox(height: context.screenHeight * 0.3),
            const Text(
              'Monopoly Banking',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            _nameInput(),
            _LoginButton(submitForm),
          ],
        ),
      ),
    );
  }
}

class _nameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.m),
      child: TextFormField(
        autofillHints: const [AutofillHints.username],
        onChanged: (name) =>
            context.read<LoginCubit>().nameChanged(name.trim()),
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          labelText: 'Name',
        ),
        validator: (value) => value.isBlank ? 'Please type in your name' : null,
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
                    child: const Text('Login'),
                    onPressed: submitForm,
                  );
          },
        ),
      ),
    );
  }
}
