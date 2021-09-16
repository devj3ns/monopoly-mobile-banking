import 'dart:math';

import 'package:banking_repository/banking_repository.dart';
import 'package:confetti/confetti.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../authentication/cubit/auth_cubit.dart';
import '../../../shared_widgets.dart';
import 'bankrupt_view.dart';
import 'no_connection_view.dart';
import 'results_view.dart';
import 'wait_for_players_view.dart';
import 'widgets/animated_balance_text.dart';
import 'widgets/list_tile_card.dart';
import 'widgets/player_card.dart';
import 'widgets/transaction_card.dart';
import 'widgets/transaction_modal_bottom_sheet.dart';

class GameView extends StatefulWidget {
  const GameView({Key? key, required this.game}) : super(key: key);
  final Game game;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    super.initState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void showConfetti() {
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            const SizedBox(height: 15),
            AnimatedMoneyBalanceText(
              moneyBalance: widget.game.getPlayer(user.id).balance,
              textStyle:
                  const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
            ),
            const Divider(height: 30),
            _PayArea(game: widget.game),
            const Divider(height: 30),
            _ReceiveArea(
              game: widget.game,
              showConfetti: showConfetti,
            ),
            const Divider(height: 30),
            _TransactionHistory(game: widget.game),
          ],
        ),
        if (!widget.game.hasStarted || widget.game.players.size < 2) ...[
          WaitForPlayersView(game: widget.game),
        ] else if (widget.game.winner != null) ...[
          ResultsOverlay(game: widget.game)
        ] else if (widget.game.getPlayer(user.id).isBankrupt) ...[
          BankruptOverlay(game: widget.game)
        ] else if (widget.game.isFromCache) ...[
          const NoConnectionOverlay(),
        ],
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
          ),
        ),
      ],
    );
  }
}

class _PayArea extends StatelessWidget {
  const _PayArea({
    Key? key,
    required this.game,
  }) : super(key: key);

  final Game game;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;
    final otherNonBankruptPlayers = game.otherNonBankruptPlayers(user.id);

    return Column(
      children: [
        const IconText(
          icon: FaIcon(
            FontAwesomeIcons.handHoldingUsd,
            size: 14,
          ),
          gap: 7,
          text: Text(
            'Pay',
            style: TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 5),
        otherNonBankruptPlayers.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(game.winner != null
                    ? 'All other players are bankrupt.'
                    : 'There are no other players yet.'),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: otherNonBankruptPlayers
                    .map(
                      (player) => PlayerCard(
                        game: game,
                        player: player,
                      ),
                    )
                    .toList(),
              ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 1,
              child: ListTileCard(
                icon: FontAwesomeIcons.solidBuilding,
                text: 'Bank',
                onTap: () => context.showTransactionModalBottomSheet(
                  TransactionForm(
                    game: game,
                    transactionType: TransactionType.toBank,
                  ),
                ),
              ),
            ),
            if (game.enableFreeParkingMoney)
              Expanded(
                flex: 2,
                child: ListTileCard(
                  icon: FontAwesomeIcons.carAlt,
                  text: 'Free Parking',
                  moneyBalance: game.freeParkingMoney,
                  onTap: () => context.showTransactionModalBottomSheet(
                    TransactionForm(
                      game: game,
                      transactionType: TransactionType.toFreeParking,
                    ),
                  ),
                ),
              ),
          ],
        )
      ],
    );
  }
}

class _ReceiveArea extends StatelessWidget {
  const _ReceiveArea({
    Key? key,
    required this.game,
    required this.showConfetti,
  }) : super(key: key);

  final Game game;
  final VoidCallback showConfetti;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const IconText(
          icon: FaIcon(
            Icons.payments_outlined,
            size: 17,
          ),
          gap: 7,
          text: Text(
            'Receive',
            style: TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListTileCard(
                icon: FontAwesomeIcons.solidBuilding,
                text: 'Bank',
                onTap: () => context.showTransactionModalBottomSheet(
                  TransactionForm(
                    game: game,
                    transactionType: TransactionType.fromBank,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListTileCard(
                icon: Icons.work_rounded,
                text: 'Salary',
                onTap: () => context.showTransactionModalBottomSheet(
                  TransactionForm(
                    game: game,
                    transactionType: TransactionType.fromSalary,
                  ),
                ),
              ),
            ),
            if (game.enableFreeParkingMoney)
              Expanded(
                child: ListTileCard(
                  icon: FontAwesomeIcons.carAlt,
                  text: 'Free Parking',
                  onTap: game.freeParkingMoney <= 0
                      ? () => context.showInfoFlashbar(
                            message:
                                'Sorry, at the moment there is no free parking money.',
                            duration: 2,
                          )
                      : () => context.showTransactionModalBottomSheet(
                            TransactionForm(
                              game: game,
                              transactionType: TransactionType.fromFreeParking,
                              showConfetti: showConfetti,
                            ),
                          ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TransactionHistory extends StatelessWidget {
  const _TransactionHistory({
    Key? key,
    required this.game,
  }) : super(key: key);

  final Game game;

  @override
  Widget build(BuildContext context) {
    final transactions = game.transactionHistory.asList();

    return Column(
      children: [
        const IconText(
          icon: FaIcon(
            Icons.history_rounded,
            size: 19,
          ),
          gap: 7,
          text: Text(
            'Transaction History',
            style: TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 7),
        transactions.isEmpty
            ? Center(
                child: Column(
                  children: const [
                    FaIcon(Icons.swap_horiz_rounded),
                    Text(
                      'There are no transactions yet.\n'
                      'Use the buttons in the pay or receive area above to make a transaction.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                shrinkWrap: true,
                itemBuilder: (context, index) => TransactionCard(
                    transaction: transactions[index], game: game),
              ),
      ],
    );
  }
}
