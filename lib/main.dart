import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_strategy/url_strategy.dart';

import 'package:auth_repository/auth_repository.dart';
import 'package:banking_repository/banking_repository.dart';

import 'authentication/cubit/authentication_cubit.dart';
import 'authentication/login_screen/login_screen.dart';
import 'authentication/splash_screen/splash_screen.dart';
import 'home.dart';

void main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Make background of gesture navigation bar transparent:
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(const _MonopolyBanking());
}

class _MonopolyBanking extends StatelessWidget {
  const _MonopolyBanking({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();

    return RepositoryProvider(
      create: (_) => authRepository,
      child: BlocProvider(
        create: (_) => AuthenticationCubit(
          authRepository: authRepository,
          createUserFunction: BankingRepository.createUser,
        ),
        child: MaterialApp(
          title: 'Monopoly Banking',
          // If this is not set Localizations.localeOf(context) won't work.
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // If this is not set Localizations.localeOf(context) won't work.
          supportedLocales: const [Locale('en'), Locale('de')],
          debugShowCheckedModeBanner: false,
          home: BlocBuilder<AuthenticationCubit, AuthenticationState>(
            buildWhen: (p, c) => p.status != c.status,
            builder: (context, state) {
              switch (state.status) {
                case AuthenticationStatus.authenticated:
                  return RepositoryProvider(
                    create: (_) => BankingRepository(userId: state.user!.uid),
                    child: const Home(),
                  );
                case AuthenticationStatus.unauthenticated:
                  return const LoginScreen();
                default:
                  return const SplashScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}
