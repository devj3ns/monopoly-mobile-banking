import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fleasy/fleasy.dart';

import 'package:user_repository/user_repository.dart';

import '../../shared_widgets.dart';
import 'cubit/choose_username_cubit.dart';
import 'view/choose_username_form.dart';

class ChooseUsernamePage extends StatelessWidget {
  const ChooseUsernamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
      body: BlocProvider(
        create: (_) => ChooseUsernameCubit(
          userRepository: context.read<UserRepository>(),
        ),
        child: BlocListener<ChooseUsernameCubit, ChooseUsernameState>(
          listenWhen: (previous, current) =>
              previous.chooseUsernameResult != current.chooseUsernameResult &&
              current.chooseUsernameResult != ChooseUsernameResult.none &&
              current.chooseUsernameResult != ChooseUsernameResult.success,
          listener: (context, state) {
            switch (state.chooseUsernameResult) {
              case ChooseUsernameResult.usernameAlreadyTaken:
                context.showInfoFlashbar(
                    message: 'Sorry, this username is already taken!');
                break;
              case ChooseUsernameResult.noConnection:
                context.showNoConnectionFlashbar();
                break;
              case ChooseUsernameResult.failure:
              default:
                context.showErrorFlashbar();
                break;
            }

            context.read<ChooseUsernameCubit>().resetSignInResult();
          },
          child: const ChooseUsernameForm(),
        ),
      ),
      applyPadding: false,
    );
  }
}
