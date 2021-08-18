import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:banking_repository/banking_repository.dart';

import '../../app/cubit/app_cubit.dart';
import '../../app_info_screen.dart';
import '../../extensions.dart';
import '../../shared_widgets.dart';
import '../create_game_screen/create_game_screen.dart';

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
      body: const _SelectGameView(),
    );
  }
}

class _SelectGameView extends StatelessWidget {
  const _SelectGameView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppCubit>().state.user;

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
                children: games.map((game) {
              return Card(
                child: ListTile(
                  title: Text('#${game.id}'),
                  trailing: Text(
                    '${game.players.size} ${Intl.plural(game.players.size, zero: 'Players', one: 'Player', other: 'Players')}',
                  ),
                  onTap: () => context.read<BankingRepository>().joinGame(game),
                ),
              );
            }).toList());
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
