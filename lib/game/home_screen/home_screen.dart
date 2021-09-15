import 'package:banking_repository/banking_repository.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import '../../app_info_screen.dart';
import '../../authentication/cubit/auth_cubit.dart';
import '../../shared_widgets.dart';
import 'cubit/join_game_cubit.dart';
import 'view/home_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void showAnonymousLogoutWarning(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext _) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'You are currently signed in to an anonymous account.'
            'This means your account gets deleted when you sign out, and you cannot re-login.\n\n'
            'If you only want to change your username, you can also do that on the home screen.\n\n'
            'We generally recommend using a social login so that you can re-login and also login to your account from other devices.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Sign out anyway'),
              onPressed: () => context
                ..read<AuthCubit>().signOut()
                ..popPage(),
            ),
          ],
        );
      },
    );
  }

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
                  icon: Icon(Icons.info_outline_rounded, color: Colors.grey),
                  gap: 10,
                  iconAfterText: false,
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
              ),
              const PopupMenuItem(
                value: 1,
                child: IconText(
                  text: Text('Sign out'),
                  icon: Icon(Icons.logout, color: Colors.grey),
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
                  if (context
                      .read<UserRepository>()
                      .firebaseAuth
                      .currentUser!
                      .isAnonymous) {
                    showAnonymousLogoutWarning(context);
                  } else {
                    context.read<AuthCubit>().signOut();
                  }
                  break;
                default:
                  break;
              }
            },
          ),
        ],
      ),
      applyPadding: false,
      body: BlocProvider<JoinGameCubit>(
        create: (_) => JoinGameCubit(
          bankingRepository: context.read<BankingRepository>(),
        ),
        child: BlocListener<JoinGameCubit, JoinGameState>(
            listenWhen: (previous, current) =>
                previous.joinGameResult != current.joinGameResult &&
                current.joinGameResult != JoinGameResult.none &&
                current.joinGameResult != JoinGameResult.success,
            listener: (context, state) {
              switch (state.joinGameResult) {
                case JoinGameResult.noConnection:
                  context.showNoConnectionFlashbar();
                  break;
                case JoinGameResult.gameNotFound:
                  context.showErrorFlashbar(
                      message: 'There is no game with this ID.');
                  break;
                case JoinGameResult.hasAlreadyStarted:
                  context.showErrorFlashbar(
                      message: 'This game has already started.');
                  break;
                case JoinGameResult.tooManyPlayers:
                  context.showErrorFlashbar(
                      message: 'A game is limited to a maximum of 6 players.');
                  break;
                default:
                  context.showErrorFlashbar();
                  break;
              }

              context.read<JoinGameCubit>().resetJoinGameResult();
            },
            child: const HomeView()),
      ),
    );
  }
}
