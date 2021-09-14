import 'package:banking_repository/banking_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:user_repository/user_repository.dart';

import '../../authentication/login_screen/login_page.dart';
import '../../authentication/set_username_screen/set_username_page.dart';
import '../../game/game_screen/game_screen.dart';
import '../../game/home_screen/home_screen.dart';
import '../cubit/app_cubit.dart';

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          if (state.isAuthenticated || state.isNewlyAuthenticated) {
            final user = state.user;

            assert(!user.isNone);

            return !user.hasUsername
                ? const SetUsernamePage(editUsername: false)
                : RepositoryProvider(
                    create: (_) => BankingRepository(
                        userRepository: context.read<UserRepository>()),
                    child: user.currentGameId != null
                        ? const GameScreen()
                        : const HomeScreen(),
                  );
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
