import 'package:auth_repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'extensions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hey ${context.user.firstName}!'),
            ElevatedButton(
              onPressed: () => context.read<AuthRepository>().signOut(),
              child: const Text('Logout'),
            )
          ],
        ),
      ),
    );
  }
}
