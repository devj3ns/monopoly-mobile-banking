import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:banking_repository/banking_repository.dart';

import '../../../app/cubit/app_cubit.dart';
import '../../../extensions.dart';
import '../../../shared_widgets.dart';
import '../../create_game_screen/create_game_screen.dart';

class SelectGameView extends StatelessWidget {
  const SelectGameView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppCubit>().state.user;

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        const SizedBox(height: 20),
        Text(
          'Hey ${user.name} 👋',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline5,
        ),
        if (user.wins > 0) ...[
          const SizedBox(height: 5),
          Text(
            'You won ${user.wins} ${Intl.plural(user.wins, one: 'game', other: 'games')}!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
        const SizedBox(height: 50),
        Text(
          'Join game:',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 10),
        EasyStreamBuilder<List<Game>>(
          stream: context.bankingRepository().allActiveGames,
          loadingIndicator: const Center(child: CircularProgressIndicator()),
          isEmptyText: 'There are no active games at the moment.',
          dataBuilder: (context, games) {
            //debugPrint('GAME LIST STREAM BUILDER REBUILDS');
            //debugPrint(games.toString());

            return Column(
                children:
                    games.map((game) => _GameListTileCard(game)).toList());
          },
        ),
        const SizedBox(height: 5),
        Center(
          child: ElevatedButton(
            child: const IconText(
              text: Text('Create game'),
              icon: Icon(Icons.add_rounded),
            ),
            onPressed: () => context.pushPage(
              CreateGameScreen(
                  bankingRepository: context.read<BankingRepository>()),
            ),
          ),
        )
      ],
    );
  }
}

class _GameListTileCard extends StatelessWidget {
  const _GameListTileCard(this.game, {Key? key}) : super(key: key);
  final Game game;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppCubit>().state.user;

    return Card(
      child: ListTile(
        title: Text('#${game.id}'),
        trailing: Text(
          '${game.players.size} ${Intl.plural(game.players.size, zero: 'Players', one: 'Player', other: 'Players')}',
        ),
        onTap: () {
          final wasAlreadyConnectedToGame = game.players
              .asList()
              .where((player) => player.userId == user.id)
              .isNotEmpty;

          if (game.players.size >= 6 && !wasAlreadyConnectedToGame) {
            context.showInfoFlashbar(
                message: 'A game is limited to a maximum of 6 players.');
          } else {
            context.read<BankingRepository>().joinGame(game);
          }
        },
      ),
    );
  }
}
