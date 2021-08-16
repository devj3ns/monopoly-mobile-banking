import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import '../shared_widgets.dart';
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
        child: const LoginForm(),
      ),
      applyPadding: false,
    );
  }
}
