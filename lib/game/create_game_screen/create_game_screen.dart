import 'package:banking_repository/banking_repository.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';

import '../../shared_widgets.dart';
import 'cubit/create_game_cubit.dart';
import 'view/create_game_form.dart';

class CreateGameScreen extends StatelessWidget {
  const CreateGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
      appBar: AppBar(
        title: const Text('Create game'),
      ),
      applyPadding: false,
      body: BlocProvider<CreateGameCubit>(
        create: (_) => CreateGameCubit(
          bankingRepository: context.read<BankingRepository>(),
        ),
        child: BlocListener<CreateGameCubit, CreateGameState>(
          listenWhen: (previous, current) =>
              previous.gameId != current.gameId ||
              previous.joiningFailed != current.joiningFailed,
          listener: (context, state) {
            if (state.gameId != null && !state.joiningFailed) {
              Routemaster.of(context).replace('/game/${state.gameId}');
            } else {
              context
                ..showErrorFlashbar()
                ..read<CreateGameCubit>()
                    .emit(state.copyWith(joiningFailed: false));
            }
          },
          child: const CreateGameForm(),
        ),
      ),
    );
  }
}
