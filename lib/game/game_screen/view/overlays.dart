import 'dart:math';

import 'package:banking_repository/banking_repository.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/cubit/app_cubit.dart';
import '../../../shared_widgets.dart';

class NoConnectionOverlay extends StatelessWidget {
  const NoConnectionOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 70,
            ),
            const SizedBox(height: 10),
            Text(
              'No connection',
              style: Theme.of(context).textTheme.headline5,
            ),
            const SizedBox(height: 5),
            Text(
              'Please check your internet connection.',
              style: Theme.of(context).textTheme.bodyText2,
            )
          ],
        ),
      ),
    );
  }
}

class BankruptOverlay extends StatelessWidget {
  const BankruptOverlay({Key? key, required this.game}) : super(key: key);
  final Game game;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppCubit>().state.user;
    final player = game.getPlayer(user.id);
    assert(player.isBankrupt);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(
              Icons.money_off,
              size: 70,
            ),
            const SizedBox(height: 15),
            Text(
              'You are bankrupt!',
              style: Theme.of(context).textTheme.headline5,
            ),
            const SizedBox(height: 5),
            Text(
                'Your Place: ${player.place(game)} (You went bankrupt after ${player.bankruptTime(game).inMinutes} min)'),
          ],
        ),
      ),
    );
  }
}

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
    final user = context.read<AppCubit>().state.user;
    final thisPlayerIsWinner = widget.game.winner!.userId == user.id;
    final winnerNameOrYou =
        thisPlayerIsWinner ? 'You' : widget.game.winner!.name;
    final gameDurationInMinutes = widget.game.duration.inMinutes;

    String getShareText() {
      final firstSentence = thisPlayerIsWinner
          ? 'I just won a Monopoly round I played with the Monopoly Banking App.'
          : 'I just played Monopoly with the Monopoly Banking App.';
      const appDescription =
          "\n\nEvery player can see his money balance on his phone and make transactions through the app easily. Therefore, you don't need the play money anymore."
          '\n\nYou can try it out here: https://monopoly-banking.web.app';

      return firstSentence + appDescription;
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
                    final bankruptTimeInMinutes =
                        player.bankruptTime(widget.game).inMinutes;

                    late final IconData icon;
                    switch (player.place(widget.game)) {
                      case 2:
                        icon = Icons.looks_two_rounded;
                        break;
                      case 3:
                        icon = Icons.looks_3_rounded;
                        break;
                      case 4:
                        icon = Icons.looks_4_rounded;
                        break;
                      case 5:
                        icon = Icons.looks_5_rounded;
                        break;
                      case 6:
                        icon = Icons.looks_6_rounded;
                        break;
                      default:
                        icon = Icons.error;
                        break;
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon),
                        const SizedBox(width: 5),
                        Text(
                          '$nameOrYou (Bankrupt after $bankruptTimeInMinutes min)',
                          style: const TextStyle(fontSize: 17),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 25),
                IconText(
                  text: Text(
                    'Duration of the game: $gameDurationInMinutes min',
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
