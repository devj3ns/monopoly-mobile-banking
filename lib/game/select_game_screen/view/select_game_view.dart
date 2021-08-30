import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:banking_repository/banking_repository.dart';
import 'package:monopoly_banking/game/select_game_screen/cubit/join_game_cubit.dart';

import '../../../app/cubit/app_cubit.dart';
import '../../../extensions.dart';
import '../../../shared_widgets.dart';
import '../../create_game_screen/create_game_screen.dart';

class SelectGameView extends StatelessWidget {
  const SelectGameView({Key? key}) : super(key: key);

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
          const _NameAndWinsSection(),
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

class _NameAndWinsSection extends StatelessWidget {
  const _NameAndWinsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppCubit>().state.user;

    return Column(
      children: [
        Text(
          'Hey ${user.name} 👋',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline5,
        ),
        if (user.wins > 0) ...[
          const SizedBox(height: 5),
          Text(
            'You won ${user.wins} ${Intl.plural(user.wins, one: 'game', other: 'games')}!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
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
      validator: (v) => v.isBlank ? 'Please enter a game ID.' : null,
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
