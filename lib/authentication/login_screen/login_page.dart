import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import '../../shared/widgets.dart';
import 'cubit/login_cubit.dart';
import 'view/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
      body: BlocProvider(
        create: (_) => LoginCubit(
          userRepository: context.read<UserRepository>(),
        ),
        child: BlocListener<LoginCubit, LoginState>(
          listenWhen: (previous, current) =>
              previous.signInResult != current.signInResult &&
              current.signInResult != SignInResult.none &&
              current.signInResult != SignInResult.success,
          listener: (context, state) {
            switch (state.signInResult) {
              case SignInResult.noConnection:
                context.showNoConnectionFlashbar();
                break;
              case SignInResult.failure:
              default:
                context.showErrorFlashbar();
                break;
            }

            context.read<LoginCubit>().resetSignInResult();
          },
          child: const LoginForm(),
        ),
      ),
    );
  }
}
