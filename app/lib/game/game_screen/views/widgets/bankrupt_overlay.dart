import 'package:banking_repository/banking_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../authentication/cubit/auth_cubit.dart';
import '../../../../shared/extensions.dart';

class BankruptOverlay extends StatelessWidget {
  const BankruptOverlay({Key? key, required this.game}) : super(key: key);
  final Game game;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;
    final player = game.getPlayer(user.id);
    assert(player.isBankrupt);

    return ColoredBox(
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
                'Your Place: ${player.place(game)} (You went bankrupt after ${player.bankruptTime(game).format()})'),
          ],
        ),
      ),
    );
  }
}
