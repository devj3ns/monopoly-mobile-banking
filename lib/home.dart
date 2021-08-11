import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';

import 'package:banking_repository/banking_repository.dart';

import 'extensions.dart';
import 'game/game_screen/game_screen.dart';
import 'game/select_game_screen/select_game_screen.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EasyStreamBuilder<User>(
      stream: context.bankingRepository().streamUserData(),
      loadingIndicator: const Center(child: CircularProgressIndicator()),
      dataBuilder: (context, user) {
        //debugPrint('USER STREAM BUILDER REBUILDS');
        //debugPrint(user.toString());

        return user.currentGameId != null
            ? GameScreen(user: user)
            : SelectGameScreen(user: user);
      },
    );
  }
}
