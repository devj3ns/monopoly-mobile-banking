import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:auth_repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'authentication/cubit/authentication_cubit.dart';
import 'authentication/login_screen/login_screen.dart';
import 'authentication/splash_screen/splash_screen.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();

    return RepositoryProvider(
      create: (_) => authRepository,
      child: BlocProvider(
        create: (_) => AuthenticationCubit(
          authRepository: authRepository,
        ),
        child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
          builder: (context, state) {
            switch (state.status) {
              case AuthenticationStatus.authenticated:
                assert(state.user != null);

                //final user = state.user!;

                // todo: init other repositories

                return const _AppView();
              default:
                return const _AppView();
            }
          },
        ),
      ),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monopoly Banking',
      home: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) {
          switch (state.status) {
            case AuthenticationStatus.authenticated:
              return const HomeScreen();
            case AuthenticationStatus.unauthenticated:
              return const LoginScreen();
            default:
              return const SplashScreen();
          }
        },
      ),
    );
  }
}
