import 'package:flutter/material.dart';

import 'package:user_repository/user_repository.dart';

import 'authentication/splash_screen/splash_screen.dart';
import 'extensions.dart';
import 'game_screen/game_screen.dart';
import 'game_screen/select_game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: context.userRepository().streamUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.hasError) {
          return Text(snapshot.error?.toString() ?? 'ERROR');
        }

        assert(snapshot.data != null);
        final user = snapshot.data!;

        //debugPrint('USER STREAM REBUILDS');
        //debugPrint(user.currentGameId);

        return user.currentGameId != null
            ? GameScreen(user: user)
            : SelectGameScreen(user: user);
      },
    );
  }
}
