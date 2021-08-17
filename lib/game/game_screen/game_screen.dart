import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:banking_repository/banking_repository.dart';
import 'package:monopoly_banking/app/cubit/app_cubit.dart';

import '../../extensions.dart';
import '../../shared_widgets.dart';
import 'view/game_view.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppCubit>().state.user;
    assert(user.currentGameId != null);

    return BasicScaffold(
      appBar: AppBar(
        title: const Text('Monopoly Banking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Leave game',
            onPressed: () => context.bankingRepository().leaveGame(),
          )
        ],
      ),
      applyPadding: false,
      body: EasyStreamBuilder<Game?>(
        stream: context.bankingRepository().streamGame(user.currentGameId!),
        loadingIndicator: const Center(child: CircularProgressIndicator()),
        dataBuilder: (context, game) {
          //debugPrint('GAME STREAM BUILDER REBUILDS');
          //debugPrint(game.toString());

          if (game == null) {
            context.bankingRepository().leaveGame();
            throw ('User was disconnected from any game, because the current one does not exist anymore.');
          } else {
            return GameView(game: game);
          }
        },
      ),
    );
  }
}
