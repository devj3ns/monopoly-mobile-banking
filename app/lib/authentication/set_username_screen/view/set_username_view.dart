import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../authentication/cubit/auth_cubit.dart';
import '../../../shared/widgets.dart';
import '../cubit/set_username_cubit.dart';

class SetUsernameView extends StatelessWidget {
  const SetUsernameView({
    Key? key,
    required this.changeUsername,
  }) : super(key: key);

  final bool changeUsername;

  static final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    void submitForm() {
      if (formKey.currentState!.validate()) {
        context
          ..dismissKeyboard()
          ..read<SetUsernameCubit>().submitForm();
      }
    }

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          SizedBox(height: context.screenHeight * 0.2),
          Center(
            child: FaIcon(
              changeUsername ? FontAwesomeIcons.userPen : FontAwesomeIcons.user,
              size: 50,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            changeUsername ? 'Change username' : 'Choose a username',
            style: Theme.of(context).textTheme.headline5,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          _UsernameInput(
            submitForm,
          ),
          _SubmitFormButton(
            submitForm,
            changeUsername: changeUsername,
          ),
        ],
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  const _UsernameInput(this.submitForm);
  final VoidCallback submitForm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.m),
      child: TextFormField(
        initialValue: context.read<AuthCubit>().state.user.name,
        onChanged: (name) =>
            context.read<SetUsernameCubit>().onUsernameChanged(name.trim()),
        onEditingComplete: submitForm,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          labelText: 'Username',
        ),
        validator: (value) => value.isBlank
            ? 'Please enter a username'
            : value!.trim().length < 2
                ? 'This username is too short'
                : value.trim().length > 15
                    ? 'This username is too long'
                    : null,
      ),
    );
  }
}

class _SubmitFormButton extends StatelessWidget {
  const _SubmitFormButton(this.submitForm, {required this.changeUsername});
  final VoidCallback submitForm;
  final bool changeUsername;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: Insets.m),
        child: BlocBuilder<SetUsernameCubit, SetUsernameState>(
          buildWhen: (previous, current) =>
              previous.isSubmitting != current.isSubmitting ||
              previous.username != current.username,
          builder: (context, state) {
            return state.isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    child: IconText(
                      text: Text(changeUsername ? 'Save' : 'Sign in'),
                      icon: Icon(
                        changeUsername
                            ? Icons.save_rounded
                            : Icons.login_rounded,
                        size: 21,
                      ),
                    ),
                    onPressed: user.name == state.username ? null : submitForm,
                  );
          },
        ),
      ),
    );
  }
}
