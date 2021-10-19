import 'package:banking_repository/banking_repository.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:routemaster/routemaster.dart';
import 'package:user_repository/user_repository.dart';

import '../../../authentication/cubit/auth_cubit.dart';
import '../../../shared/extensions.dart';
import '../../../shared/widgets.dart';
import '../create_game_form/create_game_form.dart';
import 'widgets/game_result_card.dart';
import 'widgets/join_game_form.dart';
import 'widgets/menu_button.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;

    // Not ideal but we have to set the currentGameId to null if the game is over but the currentGameId is not null yet.
    // todo: Create cloud function which updates the currentGameId and adds the game result object to each user when the game has a winner?!
    if (Routemaster.of(context).currentRoute.path == '/' &&
        user.currentGameId != null &&
        user.playedGameResultsContainsGameWithId(user.currentGameId!)) {
      context.read<UserRepository>().setCurrentGameId(null);
    }

    return Stack(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: const [
                  _UsernameSection(),
                  SizedBox(height: 15),
                  _JoinAndCreateGameSection(),
                  Divider(height: 25),
                  _PlayedGamesSection(),
                ],
              ),
            ),
          ),
        ),
        if (user.currentGameId != null &&
            !user.playedGameResultsContainsGameWithId(user.currentGameId!))
          const _RunningGameInfoModal(),
      ],
    );
  }
}

class _UsernameSection extends StatelessWidget {
  const _UsernameSection({Key? key}) : super(key: key);

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

  void showMenuModalBottomSheet(BuildContext context) {
    context.showModalBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MenuButton(
            icon: Icons.edit_outlined,
            label: 'Change username',
            onPressed: () => Routemaster.of(context).push('/change-username'),
          ),
          MenuButton(
            icon: Icons.info_outline_rounded,
            label: 'About the app',
            onPressed: () => Routemaster.of(context).push('/about'),
          ),
          MenuButton(
            icon: Icons.logout_rounded,
            label: 'Logout',
            onPressed: () =>
                context.read<UserRepository>().currentUserIsAnonymous
                    ? showAnonymousLogoutWarning(context)
                    : context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.sort_rounded,
                  size: 28,
                ),
                onPressed: () => showMenuModalBottomSheet(context),
              ),
              Flexible(
                child: Text(
                  'Hey ${user.name}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              InkWell(
                customBorder: const CircleBorder(),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  child: user.photoURL.isNotBlank
                      ? ProfilePicture(
                          photoURL: user.photoURL!,
                          radius: 22,
                        )
                      : Text(user.name.isBlank ? '' : user.name[0]),
                ),
                onTap: () => showMenuModalBottomSheet(context),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _JoinAndCreateGameSection extends StatelessWidget {
  const _JoinAndCreateGameSection({Key? key}) : super(key: key);

  void showJoinGameModalBottomSheet(BuildContext context) {
    context.showModalBottomSheet(
      child: const JoinGameForm(),
    );
  }

  void showCreateGameModalBottomSheet(BuildContext context) {
    context.showModalBottomSheet(
      child: const CreateGameForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BigGradientButton(
          label: 'Join game',
          gradientColors: context.isDarkMode
              ? const [
                  Colors.blueAccent,
                  Colors.indigo,
                ]
              : const [
                  Colors.lightBlueAccent,
                  Colors.blueAccent,
                  Colors.indigo,
                ],
          icon: Icons.login_rounded,
          onTap: () => showJoinGameModalBottomSheet(context),
        ),
        const SizedBox(height: 10),
        BigGradientButton(
          label: 'Create game',
          gradientColors: context.isDarkMode
              ? const [
                  Colors.purple,
                  Colors.deepPurple,
                ]
              : const [
                  Colors.purpleAccent,
                  Colors.purple,
                  Colors.deepPurple,
                ],
          icon: Icons.add_rounded,
          onTap: () => showCreateGameModalBottomSheet(context),
        ),
      ],
    );
  }
}

class _PlayedGamesSection extends StatelessWidget {
  const _PlayedGamesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;

    return Column(
      children: [
        Text(
          'Statistics:',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 10),
        Text(
          'Played: ${user.gamesPlayed} • Won: ${user.gamesWon}\n Total Playtime: ${user.totalPlayingTime.format()}',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: user.playedGameResults.length,
          itemBuilder: (BuildContext context, int index) => GameResultCard(
            gameResult: user.playedGameResults[index],
          ),
        ),
      ],
    );
  }
}

class _RunningGameInfoModal extends HookWidget {
  const _RunningGameInfoModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    assert(user.currentGameId != null);

    final isSubmitting = useState(false);

    return ColoredBox(
      color: Colors.black87.withOpacity(0.6),
      child: AlertDialog(
        title: const Center(
          child: FaIcon(
            Icons.nearby_error_rounded,
            size: 35,
          ),
        ),
        content: Text(
          'You are still connected to a running game (Game #${user.currentGameId!}).',
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 10),
        actions: isSubmitting.value
            ? <Widget>[
                const CircularProgressIndicator(),
              ]
            : <Widget>[
                ElevatedButton(
                  onPressed: () => Routemaster.of(context)
                      .replace('/game/${user.currentGameId!}'),
                  child: const Text('Join back'),
                ),
                OutlinedButton(
                  child: const Text('Quit (go bankrupt)'),
                  onPressed: () async {
                    isSubmitting.value = true;
                    await context
                        .read<BankingRepository>()
                        .quitGame(user.currentGameId!);
                    //isSubmitting.value = false;
                  },
                ),
              ],
      ),
    );
  }
}
