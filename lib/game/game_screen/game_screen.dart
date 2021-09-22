import 'package:banking_repository/banking_repository.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:routemaster/routemaster.dart';
import 'package:user_repository/user_repository.dart';

import '../../authentication/cubit/auth_cubit.dart';
import '../../extensions.dart';
import '../../shared_widgets.dart';
import 'views/game_view.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key, required this.gameId}) : super(key: key);
  final String gameId;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;

    return RepositoryProvider(
      create: (_) => BankingRepository(
        userRepository: context.read<UserRepository>(),
      ),
      child: user.currentGameId != null && user.currentGameId == gameId
          ? _JoinedGameScreen(gameId: gameId)
          : _JoiningGameScreen(gameId: gameId),
    );
  }
}

class _JoiningGameScreen extends StatelessWidget {
  const _JoiningGameScreen({Key? key, required this.gameId}) : super(key: key);
  final String gameId;

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
      appBar: AppBar(
        title: Text('Game #$gameId'),
      ),
      body: EasyFutureBuilder<JoinGameResult>(
        future: context.bankingRepository().joinGame(gameId),
        dataBuilder: (context, joinGameResult) {
          late final String infoText;
          late final IconData icon;
          switch (joinGameResult) {
            case JoinGameResult.gameNotFound:
              infoText =
                  'There is no game with this ID. Are you sure you entered the correct ID?';
              icon = Icons.error_outline_rounded;
              break;
            case JoinGameResult.noConnection:
              infoText =
                  'A connection to the server cannot be established. Are you connected to the internet?';
              icon = Icons.wifi_off_rounded;
              break;
            case JoinGameResult.tooManyPlayers:
              infoText = 'There are already 6 players connected to this game.';
              icon = FontAwesomeIcons.usersSlash;
              break;
            case JoinGameResult.hasAlreadyStarted:
              infoText = 'This game was already started.';
              icon = Icons.update_rounded;
              break;
            case JoinGameResult.failure:
              infoText = 'Oops.';
              icon = Icons.error_outline_rounded;
              break;
            case JoinGameResult.none:
            case JoinGameResult.success:
              infoText = 'Successfully joined the game';
              icon = Icons.done_rounded;
              break;
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                icon,
                size: icon.fontPackage == 'font_awesome_flutter' ? 35.0 : 39.0,
              ),
              const SizedBox(height: 10),
              Text(
                infoText,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Routemaster.of(context).push('/'),
                child: const Text('Back to home screen'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _JoinedGameScreen extends StatelessWidget {
  const _JoinedGameScreen({Key? key, required this.gameId}) : super(key: key);
  final String gameId;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;

    return EasyStreamBuilder<Game?>(
      stream: context.bankingRepository().streamGame(gameId),
      loadingIndicator: const Center(child: CircularProgressIndicator()),
      dataBuilder: (context, game) {
        assert(user.currentGameId != null);
        assert(user.currentGameId == gameId);

        if (game == null) {
          context.read<UserRepository>().setCurrentGameId(null);
          throw ('CurrentGameId was set to null, because streaming the game #$gameId failed.');
        } else {
          return BasicScaffold(
            appBar: AppBar(
              title: Text('Game #${game.id}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Leave game',
                  onPressed: () {
                    if (game.hasWinner) {
                      context.read<UserRepository>().setCurrentGameId(null);
                    }

                    Routemaster.of(context).push('/');
                  },
                ),
              ],
            ),
            applyPadding: false,
            body: GameView(game: game),
          );
        }
      },
    );
  }
}
