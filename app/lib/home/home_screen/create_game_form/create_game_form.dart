import 'package:banking_repository/banking_repository.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';

import 'cubit/create_game_cubit.dart';
import 'view/create_game_view.dart';

class CreateGameForm extends StatelessWidget {
  const CreateGameForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateGameCubit>(
      create: (_) => CreateGameCubit(
        bankingRepository: context.read<BankingRepository>(),
      ),
      child: BlocListener<CreateGameCubit, CreateGameState>(
        listenWhen: (previous, current) =>
            previous.gameId != current.gameId ||
            previous.joiningFailed != current.joiningFailed,
        listener: (context, state) {
          if (state.gameId != null && !state.joiningFailed) {
            Navigator.of(context).pop();
            Routemaster.of(context).replace('/game/${state.gameId}');
          } else {
            context
              ..showErrorFlashbar()
              ..read<CreateGameCubit>().resetJoiningFailed();
          }
        },
        child: const CreateGameView(),
      ),
    );
  }
}
