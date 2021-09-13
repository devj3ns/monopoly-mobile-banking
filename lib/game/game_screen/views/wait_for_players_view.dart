import 'package:banking_repository/banking_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../app/cubit/app_cubit.dart';
import '../../../shared_widgets.dart';
import 'widgets/list_tile_card.dart';

class WaitForPlayersView extends StatelessWidget {
  const WaitForPlayersView({Key? key, required this.game}) : super(key: key);
  final Game game;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppCubit>().state.user;
    final player = game.getPlayer(user.id);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: game.players
                    .asList()
                    .map(
                      (player) => ListTileCard(
                        icon: player.isGameCreator
                            ? FontAwesomeIcons.userCog
                            : FontAwesomeIcons.userAlt,
                        text: player.userId == user.id
                            ? '${player.name} (You)'
                            : player.name,
                        customColor: player.color,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              if (player.isGameCreator) ...[
                ElevatedButton(
                  child: const IconText(
                    text: Text('Start game'),
                    gap: 12,
                    icon: FaIcon(
                      FontAwesomeIcons.play,
                      size: 16,
                    ),
                  ),
                  onPressed: game.players.size > 1
                      ? () => context.read<BankingRepository>().startGame(game)
                      : null,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Note: When you start the game nobody can join anymore.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Text(
                  'Wait for ${game.gameCreator().name} to start the game.',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
