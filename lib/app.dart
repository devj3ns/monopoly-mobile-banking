import 'package:banking_repository/banking_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:user_repository/user_repository.dart';

import 'authentication/cubit/auth_cubit.dart';
import 'authentication/login_screen/login_page.dart';
import 'authentication/set_username_screen/set_username_screen.dart';
import 'game/game_screen/game_screen.dart';
import 'game/home_screen/home_screen.dart';

class App extends StatelessWidget {
  const App({Key? key, required this.userRepository}) : super(key: key);
  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => userRepository,
      child: BlocProvider(
        create: (_) => AuthCubit(userRepository: userRepository),
        child: MaterialApp(
          title: 'Monopoly Banking',
          theme: ThemeData(brightness: Brightness.light),
          darkTheme: ThemeData(brightness: Brightness.dark),
          themeMode: ThemeMode.system,
          // If this is not set Localizations.localeOf(context) won't work.
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // If this is not set Localizations.localeOf(context) won't work.
          supportedLocales: const [Locale('en'), Locale('de')],
          debugShowCheckedModeBanner: false,
          home: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state.isAuthenticated) {
                assert(!state.user.isNone);

                return state.user.hasUsername
                    ? RepositoryProvider(
                        create: (_) =>
                            BankingRepository(userRepository: userRepository),
                        child: state.user.currentGameId != null
                            ? const GameScreen()
                            : const HomeScreen(),
                      )
                    : const SetUsernameScreen(editUsername: false);
              } else {
                return const LoginPage();
              }
            },
          ),
        ),
      ),
    );
  }
}
