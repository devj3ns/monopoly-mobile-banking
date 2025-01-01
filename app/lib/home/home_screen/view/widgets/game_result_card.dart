import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:user_repository/user_repository.dart';

import '../../../../authentication/cubit/auth_cubit.dart';
import '../../../../shared/extensions.dart';
import '../../../../shared/widgets.dart';

class GameResultCard extends StatelessWidget {
  const GameResultCard({Key? key, required this.gameResult}) : super(key: key);
  final GameResult gameResult;

  IconData getIconByPlace(int place) {
    switch (place) {
      case 1:
        return Icons.emoji_events_rounded;
      case 2:
        return Icons.looks_two_rounded;
      case 3:
        return Icons.looks_3_rounded;
      case 4:
        return Icons.looks_4_rounded;
      case 5:
        return Icons.looks_5_rounded;
      case 6:
        return Icons.looks_6_rounded;
      default:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;

    final places = gameResult.places.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return ExpansionCard(
      headerPadding: const EdgeInsets.fromLTRB(12, 8, 0, 8),
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Game #${gameResult.gameId}'),
          Text(
            gameResult.startingTimestamp.formatTimestamp(),
            style: TextStyle(
              color: context.isDarkMode
                  ? Colors.white.withOpacity(0.6)
                  : Colors.black54,
            ),
          ),
        ],
      ),
      bodyPadding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      body: Column(
        children: [
          Column(
            children: places.map((playerWithPlace) {
              final name = playerWithPlace.key;
              final place = playerWithPlace.value;

              // todo:
              // This is not ideal because the username could be different now! It would be better to store the users id too.
              final nameOrYou = name == user.name ? 'You' : name;

              return Row(
                children: [
                  Icon(getIconByPlace(place)),
                  const SizedBox(width: 5),
                  Text(nameOrYou),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          IconText(
            text: Text(gameResult.duration.format()),
            gap: 7,
            icon: const FaIcon(
              FontAwesomeIcons.solidClock,
              size: 17,
            ),
            iconAfterText: false,
          ),
        ],
      ),
    );
  }
}
