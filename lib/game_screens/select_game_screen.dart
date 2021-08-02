import 'package:flutter/material.dart';
import 'package:fleasy/fleasy.dart';

import 'package:user_repository/user_repository.dart';

import '../extensions.dart';
import '../shared_widgets.dart';
import 'app_info_screen.dart';

class SelectGameScreen extends StatelessWidget {
  const SelectGameScreen({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  Widget build(BuildContext context) {
    return BasicListViewScaffold(
      appBar: AppBar(
        title: const Text('Monopoly Banking'),
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
                  text: 'About the App',
                  icon: Icons.info_outline_rounded,
                  gap: 10,
                  iconAfterText: false,
                  color: Colors.black87,
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
              ),
              const PopupMenuItem(
                value: 1,
                child: IconText(
                  text: 'Sign out',
                  icon: Icons.logout,
                  gap: 10,
                  iconAfterText: false,
                  color: Colors.black87,
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
              ),
            ],
            onSelected: (int selected) {
              switch (selected) {
                case 0:
                  context.pushPage(const AppInfoScreen());
                  break;
                case 1:
                  context.authRepository().signOut();
                  break;
                default:
                  break;
              }
            },
          ),
        ],
      ),
      children: [
        const SizedBox(height: 20),
        Text(
          'Hey ${user.name} 👋',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 50),
        const Text(
          'Lobbys:',
          textAlign: TextAlign.center,
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

            return games.isEmpty
                ? const Text(
                    "There are no lobby's yet.",
                    textAlign: TextAlign.center,
                  )
                : Column(
                    children: games.map((game) {
                    return Card(
                        child: ListTile(
                            leading: Text(game.id),
                            trailing: Text('${game.players.size} Players'),
                            onTap: () => game.join(user)));
                  }).toList());
          },
        ),
        const SizedBox(height: 5),
        const Center(
          child: ElevatedButton(
            child: IconText(
              text: 'Create lobby',
              icon: Icons.add_rounded,
            ),
            onPressed: Game.newOne,
          ),
        )
      ],
    );
  }
}
