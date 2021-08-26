import 'package:flutter/material.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/cubit/app_cubit.dart';
import '../../app_info_screen.dart';
import '../../shared_widgets.dart';
import 'view/select_game_view.dart';

class SelectGameScreen extends StatelessWidget {
  const SelectGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
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
                  context.pushPage(const AppInfoScreen());
                  break;
                case 1:
                  context.read<AppCubit>().signOut();
                  break;
                default:
                  break;
              }
            },
          ),
        ],
      ),
      applyPadding: false,
      body: const SelectGameView(),
    );
  }
}
