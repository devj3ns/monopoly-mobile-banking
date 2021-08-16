import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:user_repository/user_repository.dart';

import 'cubit/app_cubit.dart';
import 'view/app_view.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
    required this.userRepository,
  }) : super(key: key);

  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => userRepository,
      child: BlocProvider(
        create: (_) => AppCubit(userRepository: userRepository),
        child: const AppView(),
      ),
    );
  }
}
