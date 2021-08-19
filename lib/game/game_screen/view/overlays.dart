import 'dart:math';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:banking_repository/banking_repository.dart';

import '../../../app/cubit/app_cubit.dart';

class WaitForPlayersOverlay extends StatelessWidget {
  const WaitForPlayersOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.userFriends,
              size: 60,
            ),
            const SizedBox(height: 15),
            Text(
              'Wait for players to connect.',
              style: Theme.of(context).textTheme.headline5,
            )
          ],
        ),
      ),
    );
  }
}

class YouAreBankruptOverlay extends StatelessWidget {
  const YouAreBankruptOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            )
          ],
        ),
      ),
    );
  }
}

class SomeOneWonOverlay extends StatefulWidget {
  const SomeOneWonOverlay({Key? key, required this.winner}) : super(key: key);
  final Player winner;

  @override
  _SomeOneWonOverlayState createState() => _SomeOneWonOverlayState();
}

class _SomeOneWonOverlayState extends State<SomeOneWonOverlay> {
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
    final user = context.read<AppCubit>().state.user;

    return ConfettiWidget(
      confettiController: _confettiController,
      blastDirection: pi / 2,
      blastDirectionality: BlastDirectionality.explosive,
      particleDrag: 0.05,
      emissionFrequency: 0.05,
      numberOfParticles: 25,
      gravity: 0.05,
      child: Container(
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
                '${widget.winner.userId == user.id ? 'You' : widget.winner.name} won the game!',
                style: Theme.of(context).textTheme.headline5,
              )
            ],
          ),
        ),
      ),
    );
  }
}
