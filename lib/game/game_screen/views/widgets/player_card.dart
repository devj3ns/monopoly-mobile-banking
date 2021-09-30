import 'package:banking_repository/banking_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/extensions.dart';
import 'list_tile_card.dart';
import 'transaction_form.dart';

class PlayerCard extends StatelessWidget {
  const PlayerCard({
    Key? key,
    required this.game,
    required this.player,
  }) : super(key: key);

  final Game game;
  final Player player;

  @override
  Widget build(BuildContext context) {
    return ListTileCard(
      icon: FontAwesomeIcons.solidUser,
      text: player.name,
      moneyBalance: player.balance,
      customColor: player.color,
      onTap: () => context.showModalBottomSheet(
        child: TransactionForm(
          game: game,
          transactionType: TransactionType.toPlayer,
          toUserId: player.userId,
        ),
      ),
    );
  }
}
