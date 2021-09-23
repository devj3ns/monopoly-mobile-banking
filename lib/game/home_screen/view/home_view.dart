import 'package:banking_repository/banking_repository.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:routemaster/routemaster.dart';
import 'package:user_repository/user_repository.dart';

import '../../../authentication/cubit/auth_cubit.dart';
import '../../../shared_widgets.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;

    // Not ideal but we have to set the currentGameId to null if a finished game which is is left.
    if (Routemaster.of(context).currentRoute.path == '/' &&
        user.currentGameId != null &&
        user.playedGamesIds.contains(user.currentGameId)) {
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
                children: [
                  const SizedBox(height: 20),
                  const _UserSection(),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  Text(
                    'Join game:',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 10),
                  _JoinGameForm(),
                  const Divider(height: 25),
                  Text(
                    'Create game:',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 10),
                  const _CreateGameButton(),
                ],
              ),
            ),
          ),
        ),
        if (user.currentGameId != null &&
            !user.playedGamesIds.contains(user.currentGameId))
          const _RunningGameInfoModal(),
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
                      .push('/game/${user.currentGameId!}'),
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

class _UserSection extends StatelessWidget {
  const _UserSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;

    return Column(
      children: [
        if (user.photoURL != null)
          ProfilePicture(
            photoURL: user.photoURL!,
            radius: 20,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hey ${user.name} 👋',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5,
            ),
            IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    Routemaster.of(context).push('/edit-username')),
          ],
        ),
        Text(
          'Statistics:\n'
          'Games played: ${user.playedGamesIds.length}\n'
          'Games won: ${user.gamesWon}\n',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _JoinGameForm extends HookWidget {
  _JoinGameForm({Key? key}) : super(key: key);

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final gameId = useState('');

    void submitForm() {
      if (formKey.currentState!.validate()) {
        Routemaster.of(context).push('/game/${gameId.value}');
      }
    }

    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Game ID',
              prefix: Text('#'),
            ),
            textCapitalization: TextCapitalization.characters,
            onChanged: (id) => gameId.value = id,
            onEditingComplete: submitForm,
            textInputAction: TextInputAction.go,
            validator: (v) => v.isBlank
                ? 'Please enter a game ID.'
                : v!.length < 4
                    ? 'The game ID must be 4 characters long.'
                    : null,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]+')),
              LengthLimitingTextInputFormatter(4),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            child: const IconText(
              text: Text('Join'),
              icon: Icon(Icons.login_rounded),
            ),
            onPressed: submitForm,
          )
        ],
      ),
    );
  }
}

class _CreateGameButton extends StatelessWidget {
  const _CreateGameButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const IconText(
          text: Text('Create game'),
          icon: Icon(Icons.add_rounded),
        ),
        onPressed: () => Routemaster.of(context).push('/create-game'),
      ),
    );
  }
}
