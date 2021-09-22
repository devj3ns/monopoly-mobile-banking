import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routemaster/routemaster.dart';
import 'package:user_repository/user_repository.dart';

import '../../authentication/cubit/auth_cubit.dart';
import '../../shared_widgets.dart';
import 'view/home_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void showAnonymousLogoutWarning(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext _) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'You are currently signed in to an anonymous account.'
            'This means your account gets deleted when you sign out, and you cannot re-login.\n\n'
            'If you only want to change your username, you can also do that on the home screen.\n\n'
            'We generally recommend using a social login so that you can re-login and also login to your account from other devices.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Sign out anyway'),
              onPressed: () => context
                ..read<AuthCubit>().signOut()
                ..popPage(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monopoly Mobile Banking'),
        actions: [
          PopupMenuButton(
            icon: const Icon(
              Icons.more_vert,
              size: 28,
            ),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<int>(
                value: 0,
                child: IconText(
                  text: Text('About the App'),
                  icon: Icon(Icons.info_outline_rounded, color: Colors.grey),
                  gap: 10,
                  iconAfterText: false,
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
              ),
              const PopupMenuItem(
                value: 1,
                child: IconText(
                  text: Text('Sign out'),
                  icon: Icon(Icons.logout, color: Colors.grey),
                  gap: 10,
                  iconAfterText: false,
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
              ),
            ],
            onSelected: (int selected) {
              switch (selected) {
                case 0:
                  Routemaster.of(context).push('/about');
                  break;
                case 1:
                  if (context
                      .read<UserRepository>()
                      .firebaseAuth
                      .currentUser!
                      .isAnonymous) {
                    showAnonymousLogoutWarning(context);
                  } else {
                    context.read<AuthCubit>().signOut();
                  }
                  break;
                default:
                  break;
              }
            },
          ),
        ],
      ),
      body: const HomeView(),
    );
  }
}
