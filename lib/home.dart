import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';

import 'package:user_repository/user_repository.dart';

import 'extensions.dart';
import 'game_screens/game_screen.dart';
import 'game_screens/select_game_screen.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EasyStreamBuilder<User>(
      stream: context.userRepository().streamUserData(),
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
