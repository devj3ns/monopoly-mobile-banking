import 'package:banking_repository/banking_repository.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../authentication/cubit/auth_cubit.dart';
import '../../../authentication/set_username_screen/set_username_screen.dart';
import '../../../shared_widgets.dart';
import '../../create_game_screen/create_game_screen.dart';
import '../cubit/join_game_cubit.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  static final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    void submitJoinGameForm() {
      if (formKey.currentState!.validate()) {
        context.read<JoinGameCubit>().onFormSubmitted();
      }
    }

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          const SizedBox(height: 20),
          const _UserSection(),
          const SizedBox(height: 50),
          Text(
            'Join game:',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: 10),
          _GameIdInput(submitJoinGameForm),
          _JoinGameButton(submitJoinGameForm),
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
                  context.pushPage(const SetUsernameScreen(editUsername: true)),
            ),
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

class _GameIdInput extends StatelessWidget {
  const _GameIdInput(this.submitForm, {Key? key}) : super(key: key);
  final VoidCallback submitForm;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        hintText: 'Game ID',
        prefix: Text('#'),
      ),
      textCapitalization: TextCapitalization.characters,
      onChanged: (v) => context.read<JoinGameCubit>().gameIdChanged(v),
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
    );
  }
}

class _JoinGameButton extends StatelessWidget {
  const _JoinGameButton(this.submitForm, {Key? key}) : super(key: key);
  final VoidCallback submitForm;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: Insets.m),
        child: BlocBuilder<JoinGameCubit, JoinGameState>(
          buildWhen: (previous, current) =>
              previous.isSubmitting != current.isSubmitting,
          builder: (context, state) {
            return state.isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    child: const IconText(
                      text: Text('Join'),
                      icon: Icon(Icons.login_rounded),
                    ),
                    onPressed: submitForm,
                  );
          },
        ),
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
        onPressed: () => context.pushPage(
          CreateGameScreen(
              bankingRepository: context.read<BankingRepository>()),
        ),
      ),
    );
  }
}
