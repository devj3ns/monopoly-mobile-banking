import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';

import '../../../shared/extensions.dart';
import '../../../shared/widgets.dart';
import '../cubit/login_cubit.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          'Monopoly Mobile Banking',
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
                      _SignInWithGoogleButton(),
                      _SignInAnonymouslyButton(),
                    ],
                  );
          },
        ),
        const Expanded(child: SizedBox()),
        TextButton(
          child: IconText(
            icon: Icon(
              Icons.info_outline_rounded,
              color: context.isDarkMode ? Colors.white70 : Colors.black54,
              size: 21,
            ),
            text: Text(
              'About the app',
              style: TextStyle(
                  color: context.isDarkMode ? Colors.white70 : Colors.black54),
            ),
          ),
          onPressed: () => Routemaster.of(context).push('/about'),
        ),
      ],
    );
  }
}

class _SignInAnonymouslyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: Insets.s),
        child: ElevatedButton(
          child: const IconText(
            text: Text('Sign in anonymously'),
            icon: Icon(Icons.login_rounded),
          ),
          onPressed: () => context.read<LoginCubit>().signInAnonymously(),
        ),
      ),
    );
  }
}

class _SignInWithGoogleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: Insets.s),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.white),
          child: const IconText(
            text: Text(
              'Sign in with Google',
              style: TextStyle(color: Colors.black54),
            ),
            gap: 8,
            icon: Image(
              image: AssetImage(
                'assets/google_logo.png',
              ),
              height: 17,
              width: 17,
            ),
          ),
          onPressed: () => context.read<LoginCubit>().signInWithGoogle(),
        ),
      ),
    );
  }
}
