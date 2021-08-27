import 'package:fleasy/fleasy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../shared_widgets.dart';
import '../cubit/choose_username_cubit.dart';

class ChooseUsernameForm extends StatelessWidget {
  const ChooseUsernameForm({Key? key}) : super(key: key);

  static final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    void submitForm() {
      if (formKey.currentState!.validate()) {
        context
          ..dismissKeyboard()
          ..read<ChooseUsernameCubit>().submitForm();
      }
    }

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          SizedBox(height: context.screenHeight * 0.2),
          const Center(
            child: FaIcon(
              FontAwesomeIcons.user,
              size: 50,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Choose a username',
            style: Theme.of(context).textTheme.headline5,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          _UsernameInput(),
          _SubmitFormButton(submitForm),
        ],
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.m),
      child: TextFormField(
        onChanged: (name) =>
            context.read<ChooseUsernameCubit>().onUsernameChanged(name.trim()),
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          labelText: 'Username',
        ),
        validator: (value) => value.isBlank
            ? 'Please enter a username'
            : value!.trim().length > 15
                ? 'The length of your username has to be below 15 characters'
                : null,
      ),
    );
  }
}

class _SubmitFormButton extends StatelessWidget {
  const _SubmitFormButton(this.submitForm);
  final VoidCallback submitForm;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: Insets.m),
        child: BlocBuilder<ChooseUsernameCubit, ChooseUsernameState>(
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
