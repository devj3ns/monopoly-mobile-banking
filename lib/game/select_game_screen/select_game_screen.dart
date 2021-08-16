import 'package:banking_repository/banking_repository.dart';
import 'package:flutter/material.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/cubit/app_cubit.dart';

import '../../app_info_screen.dart';
import '../../extensions.dart';
import '../../shared_widgets.dart';

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
                  icon: Icon(Icons.info_outline_rounded, color: Colors.black87),
                  gap: 10,
                  iconAfterText: false,
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
              ),
              const PopupMenuItem(
                value: 1,
                child: IconText(
                  text: Text('Sign out'),
                  icon: Icon(Icons.logout, color: Colors.black87),
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
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 50),
        const Text(
          'Lobbys:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        EasyStreamBuilder<List<Game>>(
          stream: context.bankingRepository().allGames,
          loadingIndicator: const Center(child: CircularProgressIndicator()),
          isEmptyText: "There are no lobby's yet.",
          dataBuilder: (context, games) {
            //debugPrint('GAME LIST STREAM BUILDER REBUILDS');
            //debugPrint(games.toString());

            return Column(
                children: games.map((game) {
              return Card(
                child: ListTile(
                  leading: Text(game.id),
                  trailing: Text('${game.players.size} Players'),
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
              text: Text('Create lobby'),
              icon: Icon(Icons.add_rounded),
            ),
            onPressed: () => context.read<BankingRepository>().newGame(),
          ),
        )
      ],
    );
  }
}
