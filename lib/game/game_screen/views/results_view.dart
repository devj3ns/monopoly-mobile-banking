import 'dart:math';

import 'package:banking_repository/banking_repository.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../authentication/cubit/auth_cubit.dart';
import '../../../extensions.dart';
import '../../../shared_widgets.dart';

class ResultsOverlay extends StatefulWidget {
  const ResultsOverlay({Key? key, required this.game}) : super(key: key);
  final Game game;

  @override
  _ResultsOverlayState createState() => _ResultsOverlayState();
}

class _ResultsOverlayState extends State<ResultsOverlay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3))..play();

    super.initState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.game.winner != null);
    final user = context.read<AuthCubit>().state.user;
    final thisPlayerIsWinner = widget.game.winner!.userId == user.id;
    final winnerNameOrYou =
        thisPlayerIsWinner ? 'You' : widget.game.winner!.name;
    final gameDuration = widget.game.duration;

    String getShareText() {
      final firstSentence = thisPlayerIsWinner
          ? 'I just won a Monopoly round I played with the Monopoly Banking App.'
          : 'I just played Monopoly with the Monopoly Banking App.';
      const appDescription =
          "\n\nEvery player can see his money balance on his phone and make transactions through the app easily. Therefore, you don't need the play money anymore."
          '\n\nYou can try it out here: https://monopoly-banking.web.app';

      return firstSentence + appDescription;
    }

    IconData getIconByPlace(int place) {
      switch (place) {
        case 2:
          return Icons.looks_two_rounded;

        case 3:
          return Icons.looks_3_rounded;

        case 4:
          return Icons.looks_4_rounded;

        case 5:
          return Icons.looks_5_rounded;

        case 6:
          return Icons.looks_6_rounded;

        default:
          return Icons.error;
      }
    }

    return Stack(
      children: [
        Container(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(
                  Icons.emoji_events_rounded,
                  size: 75,
                ),
                const SizedBox(height: 15),
                Text(
                  '$winnerNameOrYou won the game!',
                  style: Theme.of(context).textTheme.headline5,
                ),
                const SizedBox(height: 5),
                Column(
                  children: widget.game.bankruptPlayersSortedByPlace
                      .asList()
                      .map((player) {
                    final nameOrYou =
                        player.userId == user.id ? 'You' : player.name;
                    final bankruptTime = player.bankruptTime(widget.game);

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(getIconByPlace(player.place(widget.game))),
                        const SizedBox(width: 5),
                        Text(
                          '$nameOrYou (Bankrupt after ${bankruptTime.format()})',
                          style: const TextStyle(fontSize: 17),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 25),
                IconText(
                  text: Text(
                    'Duration of the game: ${gameDuration.format()}',
                    style: const TextStyle(fontSize: 17),
                  ),
                  gap: 7,
                  icon: const FaIcon(
                    FontAwesomeIcons.solidClock,
                    size: 20,
                  ),
                  iconAfterText: false,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  child: const IconText(
                    icon: Icon(Icons.share_rounded),
                    text: Text('Share'),
                  ),
                  onPressed: () => Share.share(getShareText()),
                )
              ],
            ),
          ),
        ),
        if (thisPlayerIsWinner)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              //   gravity: 0.05,
            ),
          ),
      ],
    );
  }
}
