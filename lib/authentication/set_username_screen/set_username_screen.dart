import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import '../../shared_widgets.dart';
import 'cubit/set_username_cubit.dart';
import 'view/set_username_view.dart';

class SetUsernameScreen extends StatelessWidget {
  const SetUsernameScreen({Key? key, required this.editUsername})
      : super(key: key);
  final bool editUsername;

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
      appBar: editUsername
          ? AppBar(
              title: Text(editUsername ? 'Edit username' : 'Choose username'),
            )
          : null,
      body: BlocProvider(
        create: (_) => SetUsernameCubit(
          userRepository: context.read<UserRepository>(),
        ),
        child: BlocListener<SetUsernameCubit, SetUsernameState>(
          listenWhen: (previous, current) =>
              previous.chooseUsernameResult != current.chooseUsernameResult &&
              current.chooseUsernameResult != SetUsernameResult.none,
          listener: (context, state) {
            switch (state.chooseUsernameResult) {
              case SetUsernameResult.success:
                if (editUsername) {
                  context.popPage();
                }
                break;
              case SetUsernameResult.usernameAlreadyTaken:
                context.showInfoFlashbar(
                    message: 'Sorry, this username is already taken!');
                break;
              case SetUsernameResult.noConnection:
                context.showNoConnectionFlashbar();
                break;
              case SetUsernameResult.failure:
              default:
                context.showErrorFlashbar();
                break;
            }

            context.read<SetUsernameCubit>().resetSignInResult();
          },
          child: SetUsernameView(
            editUsername: editUsername,
          ),
        ),
      ),
      applyPadding: false,
    );
  }
}
