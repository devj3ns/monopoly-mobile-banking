import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:routemaster/routemaster.dart';
import 'package:user_repository/user_repository.dart';

import 'app_info_screen.dart';
import 'authentication/cubit/auth_cubit.dart';
import 'authentication/login_screen/login_page.dart';
import 'authentication/set_username_screen/set_username_screen.dart';
import 'game/create_game_screen/create_game_screen.dart';
import 'game/game_screen/game_screen.dart';
import 'game/home_screen/home_screen.dart';

final _loggedOutRoutes = RouteMap(
  routes: {
    '/': (_) => const MaterialPage<void>(
          key: ValueKey('login'),
          child: LoginPage(),
        ),
    '/game/:gameId': (routeData) {
      final gameId = routeData.pathParameters['gameId']!.toUpperCase();

      return Redirect(
        '/',
        queryParameters: {'joingame': gameId},
      );
    },
    '/about': (routeData) => const MaterialPage<Widget>(
          key: ValueKey('about'),
          child: AppInfoScreen(),
        ),
  },
);

final _setUsernameRoutes = RouteMap(
  routes: {
    '/': (route) => const MaterialPage<void>(
          key: ValueKey('set-username'),
          child: SetUsernameScreen(editUsername: false),
        ),
  },
);

RouteMap _loggedInRoutes(User user) => RouteMap(
      routes: {
        '/': (routeData) {
          final gameId = routeData.queryParameters['joingame'];

          return gameId != null
              ? Redirect('/game/$gameId')
              : const MaterialPage<void>(
                  key: ValueKey('home'),
                  child: HomeScreen(),
                );
        },
        '/game/:gameId': (routeData) {
          final gameId = routeData.pathParameters['gameId']!.toUpperCase();

          // Redirect to home if the user is currently connected to a game but wants to join another one:
          if (user.currentGameId != null && user.currentGameId != gameId) {
            return const Redirect('/');
          }

          return MaterialPage<Widget>(
            key: ValueKey('game-$gameId'),
            child: GameScreen(
              gameId: gameId,
            ),
          );
        },
        '/about': (routeData) => const MaterialPage<Widget>(
              key: ValueKey('about'),
              child: AppInfoScreen(),
            ),
        '/edit-username': (routeData) => const MaterialPage<Widget>(
              key: ValueKey('edit-username'),
              child: SetUsernameScreen(editUsername: true),
            ),
        '/create-game': (routeData) => const MaterialPage<Widget>(
              key: ValueKey('create-game'),
              child: CreateGameScreen(),
            ),
      },
    );

final RoutemasterDelegate _routemaster = RoutemasterDelegate(
  routesBuilder: (context) {
    final authState = context.watch<AuthCubit>().state;

    return authState.isAuthenticated
        ? authState.user.hasUsername
            ? _loggedInRoutes(authState.user)
            : _setUsernameRoutes
        : _loggedOutRoutes;
  },
);

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Monopoly Mobile Banking',
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('de')],
      debugShowCheckedModeBanner: false,
      routerDelegate: _routemaster,
      routeInformationParser: const RoutemasterParser(),
    );
  }
}
