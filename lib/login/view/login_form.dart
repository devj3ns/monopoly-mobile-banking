import 'package:fleasy/fleasy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shared/shared.dart';

import '../../shared_widgets.dart';
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
          ..read<LoginCubit>().signIn();
      }
    }

    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (p, c) =>
          p.loginFailure != c.loginFailure && c.loginFailure != AppFailure.none,
      listener: (context, state) {
        //todo: show more meaningful error flashbars!
        context.showErrorFlashbar();
        context.read<LoginCubit>().resetLoginFailure();
      },
      child: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            SizedBox(height: context.screenHeight * 0.3),
            Text(
              'Monopoly Banking',
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            _NameInput(),
            _LoginButton(submitForm),
          ],
        ),
      ),
    );
  }
}

class _NameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.m),
      child: TextFormField(
        onChanged: (name) =>
            context.read<LoginCubit>().onNameChanged(name.trim()),
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          labelText: 'Name',
        ),
        validator: (value) => value.isBlank ? 'Please enter your name' : null,
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
                    child: const IconText(
                      text: Text('Sign in'),
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
