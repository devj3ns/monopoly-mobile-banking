import 'package:banking_repository/banking_repository.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../authentication/cubit/auth_cubit.dart';
import '../../../shared/extensions.dart';
import '../../../shared/widgets.dart';
import 'widgets/list_tile_card.dart';

class WaitForPlayersView extends StatelessWidget {
  const WaitForPlayersView({Key? key, required this.game}) : super(key: key);
  final Game game;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;
    final player = game.getPlayer(user.id);
    final qrCodeMaxWidth = context.screenWidth /
        (context.screenWidth > 1400
            ? 7
            : context.screenWidth > 1100
                ? 5
                : context.screenWidth > 900
                    ? 4
                    : context.screenWidth > 700
                        ? 3
                        : 2);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (player.isGameCreator) ...[
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: qrCodeMaxWidth),
                    child: QrImage(
                      data: game.link,
                      foregroundColor:
                          context.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                if (kIsWeb) const SizedBox(height: 5),
                OutlinedButton(
                  child: const IconText(
                    icon: Icon(
                      Icons.share_rounded,
                      size: 18,
                    ),
                    text: Text('Share game link'),
                  ),
                  onPressed: () => Share.share(
                    game.link,
                    subject: 'Monopoly Mobile Banking Game Link',
                  ),
                ),
                const SizedBox(height: 10),
              ],
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
                  'Wait for ${game.gameCreator.name} to start the game.',
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
