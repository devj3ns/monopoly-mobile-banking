import 'package:flutter/material.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:banking_repository/banking_repository.dart';

import '../../app/cubit/app_cubit.dart';
import '../../app_info_screen.dart';
import '../../shared_widgets.dart';
import 'cubit/join_game_cubit.dart';
import 'view/select_game_view.dart';

class SelectGameScreen extends StatelessWidget {
  const SelectGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
      appBar: AppBar(
        title: const Text('Monopoly Banking'),
        actions: [
          PopupMenuButton(
            icon: const Icon(
              Icons.more_vert,
              size: 28,
            ),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<int>(
                value: 0,
                child: IconText(
                  text: Text('About the App'),
                  icon: Icon(Icons.info_outline_rounded, color: Colors.grey),
                  gap: 10,
                  iconAfterText: false,
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
              ),
              const PopupMenuItem(
                value: 1,
                child: IconText(
                  text: Text('Sign out'),
                  icon: Icon(Icons.logout, color: Colors.grey),
                  gap: 10,
                  iconAfterText: false,
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
              ),
            ],
            onSelected: (int selected) {
              switch (selected) {
                case 0:
                  context.pushPage(const AppInfoScreen());
                  break;
                case 1:
                  context.read<AppCubit>().signOut();
                  break;
                default:
                  break;
              }
            },
          ),
        ],
      ),
      applyPadding: false,
      body: BlocProvider<JoinGameCubit>(
        create: (_) => JoinGameCubit(
          bankingRepository: context.read<BankingRepository>(),
        ),
        child: BlocListener<JoinGameCubit, JoinGameState>(
            listenWhen: (previous, current) =>
                previous.joinGameResult != current.joinGameResult &&
                current.joinGameResult != JoinGameResult.none &&
                current.joinGameResult != JoinGameResult.success,
            listener: (context, state) {
              switch (state.joinGameResult) {
                case JoinGameResult.noConnection:
                  context.showNoConnectionFlashbar();
                  break;
                case JoinGameResult.gameNotFound:
                  context.showErrorFlashbar(
                      message: 'There is no game with this ID.');
                  break;
                case JoinGameResult.hasAlreadyStarted:
                  context.showErrorFlashbar(
                      message: 'This game has already started.');
                  break;
                case JoinGameResult.tooManyPlayers:
                  context.showErrorFlashbar(
                      message: 'A game is limited to a maximum of 6 players.');
                  break;
                default:
                  context.showErrorFlashbar();
                  break;
              }

              context.read<JoinGameCubit>().resetJoinGameResult();
            },
            child: const SelectGameView()),
      ),
    );
  }
}
