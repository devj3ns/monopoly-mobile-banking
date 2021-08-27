import 'package:fleasy/fleasy.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import '../../../shared_widgets.dart';
import '../cubit/login_cubit.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void signInAnonymously() {
      showDialog<void>(
        context: context,
        builder: (BuildContext _) {
          return AlertDialog(
            title: const Text('Warning'),
            content: const Text(
                'When you create an anonymous account you can only sign in once.\n\n'
                'This means you cannot re-login after you signed out or generally login from another device.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Go ahead anyway'),
                onPressed: () {
                  context.read<LoginCubit>().signInAnonymously();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void signInWithGoogle() => context.read<LoginCubit>().signInWithGoogle();

    return Column(
      children: [
        SizedBox(height: context.screenHeight * 0.2),
        Image.asset(
          'assets/logo.png',
          width: 100,
          height: 100,
        ),
        const SizedBox(height: 25),
        Text(
          'Monopoly Banking',
          style: Theme.of(context).textTheme.headline4,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 25),
        BlocBuilder<LoginCubit, LoginState>(
          buildWhen: (previous, current) =>
              previous.isSubmitting != current.isSubmitting,
          builder: (context, state) {
            return state.isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _SignInAnonymouslyButton(signInAnonymously),
                      _SignInWithGoogleButton(signInWithGoogle),
                    ],
                  );
          },
        ),
      ],
    );
  }
}

class _SignInAnonymouslyButton extends StatelessWidget {
  const _SignInAnonymouslyButton(this.signIn);
  final VoidCallback signIn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: Insets.m),
        child: ElevatedButton(
          child: const IconText(
            text: Text('Sign in anonymously'),
            icon: Icon(Icons.login_rounded),
          ),
          onPressed: signIn,
        ),
      ),
    );
  }
}

class _SignInWithGoogleButton extends StatelessWidget {
  const _SignInWithGoogleButton(this.signIn);
  final VoidCallback signIn;

  @override
  Widget build(BuildContext context) {
    return Center(
      //ignore: avoid-wrapping-in-padding
      child: Padding(
        padding: const EdgeInsets.only(top: Insets.m),
        child: SignInButton(
          Buttons.Google,
          text: 'Sign in with Google',
          onPressed: signIn,
        ),
      ),
    );
  }
}
