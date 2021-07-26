import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fleasy/fleasy.dart';

import 'package:auth_repository/auth_repository.dart';

import 'cubit/login_cubit.dart';
import 'widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => LoginCubit(context.read<AuthRepository>()),
        child: BlocListener<LoginCubit, LoginState>(
          listenWhen: (previous, current) =>
              previous.authResult != current.authResult &&
              current.authResult != AuthResult.none &&
              current.authResult != AuthResult.success,
          listener: (context, state) {
            switch (state.authResult) {
              case AuthResult.failure:
              default:
                context.showErrorFlashbar(
                    message: 'Es ist ein Fehler aufgetreten.');
                break;
            }

            // Reset authResult so that flashbar won't be shown
            // again even if the authResult is the same
            // (e. g. two times wrong password)
            context.read<LoginCubit>().resetAuthResult();
          },
          child: const LoginForm(),
        ),
      ),
    );
  }
}
