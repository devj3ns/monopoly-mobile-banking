import 'package:flutter/material.dart';

import 'package:user_repository/user_repository.dart';

import '../extensions.dart';

class SelectGameScreen extends StatelessWidget {
  const SelectGameScreen({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => context.authRepository().signOut(),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Lobbys:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<Game>>(
              stream: context.userRepository().allGames,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text(snapshot.error?.toString() ?? 'ERROR');
                }

                final games = snapshot.data!;

                return Column(
                  children: games.map((game) {
                    return Card(
                      child: ListTile(
                        leading: Text(game.id),
                        trailing: Text('${game.players.size} Players'),
                        onTap: () => game.join(user),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const ElevatedButton(
              child: Text('Neues Spiel'),
              onPressed: Game.newOne,
            )
          ],
        ),
      ),
    );
  }
}
