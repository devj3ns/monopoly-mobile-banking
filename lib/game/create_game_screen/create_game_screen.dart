import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:banking_repository/banking_repository.dart';

import '../../shared_widgets.dart';
import 'cubit/create_game_cubit.dart';
import 'view/create_game_form.dart';

class CreateGameScreen extends StatelessWidget {
  const CreateGameScreen({Key? key, required this.bankingRepository})
      : super(key: key);
  final BankingRepository bankingRepository;

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
      appBar: AppBar(
        title: const Text('Create new public game'),
      ),
      applyPadding: false,
      body: RepositoryProvider.value(
        value: bankingRepository,
        child: Builder(
          builder: (context) => BlocProvider<CreateGameCubit>(
            create: (_) => CreateGameCubit(
              bankingRepository: context.read<BankingRepository>(),
            ),
            child: const CreateGameForm(),
          ),
        ),
      ),
    );
  }
}
