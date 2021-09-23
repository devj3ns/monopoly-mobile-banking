import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:kt_dart/kt.dart';
import 'package:ntp/ntp.dart';
import 'package:user_repository/user_repository.dart';

import '../../banking_repository.dart';
import 'player.dart';

class Game extends Equatable {
  Game({
    required this.id,
    required this.players,
    required this.transactionHistory,
    required this.startingCapital,
    required this.enableFreeParkingMoney,
    required this.freeParkingMoney,
    required this.salary,
    required this.isFromCache,
    required this.startingTimestamp,
  })  : assert(players.size <= 6),
        assert(id.toUpperCase() == id);

  // #### Attributes (are stored in the database): ####

  /// The unique id of the game.
  final String id;

  /// The players connected to this game, sorted by balance.
  final KtList<Player> players;

  /// The transaction history of this game, sorted by timestamp.
  final KtList<Transaction> transactionHistory;

  /// How much money every player gets when the game starts.
  final int startingCapital;

  /// Whether the free Payout variation is used:
  ///
  /// How it works:
  /// 1. Anytime someone pays a fee or tax (Jail, Income, Luxury, etc.), put the money in the middle of the board.
  /// 2. When someone lands on Free Parking, they get that money. If there is no money, they receive $100.
  final bool enableFreeParkingMoney;

  /// If [enableFreeParkingMoney] is true:
  /// The amount of money which is currently in the middle of the playing field.
  final int freeParkingMoney;

  /// The amount of money a player gets when going over the GO field.
  final int salary;

  /// Whether the snapshot was created from cached data rather than guaranteed up-to-date server data.
  final bool isFromCache;

  /// The date and time when the game started.
  final DateTime? startingTimestamp;

  // #### Props used for equality: ####

  @override
  List<Object?> get props => [
        id,
        players,
        startingCapital,
        transactionHistory,
        enableFreeParkingMoney,
        freeParkingMoney,
        salary,
        isFromCache,
        startingTimestamp,
      ];

  // #### Helper getters: ####

  /// Whether the game has already started.
  ///
  /// When the game is started only players who are already in the players list can join.
  bool get hasStarted => startingTimestamp != null;

  /// Returns a list of all non-bankrupt players.
  KtList<Player> get nonBankruptPlayers =>
      players.asList().where((player) => player.balance > 0).toImmutableList();

  /// Returns a list of all bankrupt players.
  KtList<Player> get bankruptPlayers =>
      players.asList().where((player) => player.balance <= 0).toImmutableList();

  /// Returns a list of all bankrupt players sorted by their place.
  ///
  /// Should only be used when someone won and the game is over.
  KtList<Player> get bankruptPlayersSortedByPlace =>
      (bankruptPlayers.asList().toList()
            ..sort((a, b) => a.place(this).compareTo(b.place(this))))
          .toImmutableList();

  /// The winner of the game (if there is one).
  Player? get winner {
    if (nonBankruptPlayers.size == 1 && players.size > 1) {
      return nonBankruptPlayers[0];
    }
  }

  /// Whether the game has a winner.
  bool get hasWinner => winner != null;

  /// Returns the player who created the game.
  Player get gameCreator =>
      players.asList().firstWhere((player) => player.isGameCreator);

  /// How long it took until one player won the game.
  ///
  /// This should only be called when someone won the game.
  Duration get duration {
    assert(startingTimestamp != null);
    assert(winner != null);

    final lastPlayerWhoWentBankrupt = bankruptPlayersSortedByPlace.first();

    return lastPlayerWhoWentBankrupt.bankruptTimestamp!
        .difference(startingTimestamp!);
  }

  /// Returns the link to this game.
  String get link => 'https://monopoly-banking.web.app/game/$id';

  // #### Helper functions: ####

  /// Whether the user was already connected to this game.
  bool containsPlayerWithId(String userId) {
    return players.indexOfFirst((player) => player.userId == userId) != -1;
  }

  /// Returns the player with the given user id.
  Player getPlayer(String userId) {
    assert(containsPlayerWithId(userId));

    return players[players.indexOfFirst((player) => player.userId == userId)];
  }

  // #### Other methods: ####

  static Game newOne({
    required String id,
    required int startingCapital,
    required int salary,
    required bool enableFreeParkingMoney,
  }) {
    return Game(
      id: id,
      players: const KtList<Player>.empty(),
      transactionHistory: const KtList<Transaction>.empty(),
      startingCapital: startingCapital,
      enableFreeParkingMoney: enableFreeParkingMoney,
      freeParkingMoney: 0,
      salary: salary,
      isFromCache: true,
      startingTimestamp: null,
    );
  }

  static Game fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final json = snap.data()!;

    final _playersSorted = (pick(json, 'players').asListOrEmpty<Player>(
            (pick) => Player.fromJson(pick.asMapOrThrow<String, dynamic>()))
          ..sort((a, b) => b.balance.compareTo(a.balance)))
        .toImmutableList();

    final _transactionHistorySorted = (pick(json, 'transactionHistory')
            .asListOrEmpty<Transaction>((pick) =>
                Transaction.fromJson(pick.asMapOrThrow<String, dynamic>()))
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp)))
        .toImmutableList();

    return Game(
      id: snap.id,
      players: _playersSorted,
      transactionHistory: _transactionHistorySorted,
      startingCapital: pick(json, 'startingCapital').asIntOrThrow(),
      enableFreeParkingMoney:
          pick(json, 'enableFreeParkingMoney').asBoolOrThrow(),
      freeParkingMoney: pick(json, 'freeParkingMoney').asIntOrThrow(),
      salary: pick(json, 'salary').asIntOrThrow(),
      isFromCache: snap.metadata.isFromCache,
      startingTimestamp: pick(json, 'startingTimestamp')
          .asFirestoreTimeStampOrNull()
          ?.toDate(),
    );
  }

  Map<String, Object?> toDocument() {
    return {
      'players': players.isEmpty()
          ? <Player>[]
          : players.map((player) => player.toJson()).asList(),
      'transactionHistory': transactionHistory.isEmpty()
          ? <Transaction>[]
          : transactionHistory
              .map((transaction) => transaction.toJson())
              .asList(),
      'startingCapital': startingCapital,
      'enableFreeParkingMoney': enableFreeParkingMoney,
      'freeParkingMoney': freeParkingMoney,
      'salary': salary,
      'winnerId': winner?.userId,
      'startingTimestamp': startingTimestamp,
    };
  }

  Game copyWith({
    KtList<Player>? players,
    KtList<Transaction>? transactionHistory,
    int? startingCapital,
    int? freeParkingMoney,
    DateTime? startingTimestamp,
  }) {
    return Game(
      id: id,
      players: players ?? this.players,
      transactionHistory: transactionHistory ?? this.transactionHistory,
      startingCapital: startingCapital ?? this.startingCapital,
      freeParkingMoney: freeParkingMoney ?? this.freeParkingMoney,
      enableFreeParkingMoney: enableFreeParkingMoney,
      salary: salary,
      isFromCache: isFromCache,
      startingTimestamp: startingTimestamp ?? this.startingTimestamp,
    );
  }

  /// Returns a new instance which represents the game after the transaction.
  ///
  /// Use custom constructors for the transaction object:
  /// For example Transaction.fromBank(...) or Transaction.toPlayer(...).
  Future<Game> makeTransaction(Transaction transaction) async {
    // Create new/updated players list:
    var _players = players.toMutableList().asList();
    var _freeParkingMoney = freeParkingMoney;

    switch (transaction.type) {
      case TransactionType.fromBank:
        assert(transaction.toUserId != null);
        // Add money to the players balance:
        final playerIndex = _players
            .indexWhere((player) => player.userId == transaction.toUserId!);
        _players[playerIndex] =
            _players[playerIndex].addMoney(transaction.amount);
        break;
      case TransactionType.toBank:
        assert(transaction.fromUserId != null);
        // Subtract money from the players balance:
        final playerIndex = _players
            .indexWhere((player) => player.userId == transaction.fromUserId!);
        _players[playerIndex] =
            _players[playerIndex].subtractMoney(transaction.amount);
        break;
      case TransactionType.toPlayer:
        assert(transaction.fromUserId != null);
        assert(transaction.toUserId != null);
        // Subtract money from the 'from player's balance:
        final fromPlayerIndex = _players
            .indexWhere((player) => player.userId == transaction.fromUserId!);
        _players[fromPlayerIndex] =
            _players[fromPlayerIndex].subtractMoney(transaction.amount);
        // Add money to the 'to player's balance:
        final toPlayerIndex = _players
            .indexWhere((player) => player.userId == transaction.toUserId!);
        _players[toPlayerIndex] =
            _players[toPlayerIndex].addMoney(transaction.amount);
        break;
      case TransactionType.toFreeParking:
        assert(transaction.fromUserId != null);
        // Subtract money from the players balance:
        final playerIndex = _players
            .indexWhere((player) => player.userId == transaction.fromUserId!);
        _players[playerIndex] =
            _players[playerIndex].subtractMoney(transaction.amount);
        // Add money to free parking:
        _freeParkingMoney += transaction.amount;
        break;
      case TransactionType.fromFreeParking:
        assert(transaction.toUserId != null);
        // Add money to the players balance:
        final playerIndex = _players
            .indexWhere((player) => player.userId == transaction.toUserId!);
        _players[playerIndex] =
            _players[playerIndex].addMoney(freeParkingMoney);
        // Set free parking money to 0:
        _freeParkingMoney = 0;
        break;
      case TransactionType.fromSalary:
        assert(transaction.toUserId != null);
        // Add money to the players balance:
        final playerIndex = _players
            .indexWhere((player) => player.userId == transaction.toUserId!);
        _players[playerIndex] = _players[playerIndex].addMoney(salary);
        break;
    }

    // Create new/updated transactions list:
    final _transactionHistory = transactionHistory.toMutableList().asList()
      ..add(transaction);

    // todo: Find a better solution for this. FieldValue.serverTimestamp() would be ideal but seems a bit complicated because the data is nested.
    // When using the web app and cellular network running NTP.now() fails.
    // This ist just a temporary fix:
    var timestamp = DateTime.now();
    try {
      timestamp = await NTP.now();
    } catch (_) {}

    // Update the players bankrupt timestamp if necessary
    _players = _players.map((player) {
      return player.isBankrupt && player.bankruptTimestamp == null
          ? player.copyWith(bankruptTimestamp: timestamp)
          : player;
    }).toList();

    return copyWith(
      players: _players.toImmutableList(),
      transactionHistory: _transactionHistory.toImmutableList(),
      freeParkingMoney: _freeParkingMoney,
    );
  }

  /// Returns a new instance which represents the the game after the player was added.
  ///
  /// When a player gets added, his start money balance and his color is set.
  Game addPlayer(User user, {bool isGameCreator = false}) {
    final _players = players.toMutableList();

    if (!containsPlayerWithId(user.id)) {
      final colors = [
        Colors.blue,
        Colors.teal,
        Colors.green,
        Colors.yellow,
        Colors.orange,
        Colors.red,
      ];

      final player = Player(
        userId: user.id,
        name: user.name,
        balance: startingCapital,
        color: colors[_players.size],
        bankruptTimestamp: null,
        isGameCreator: isGameCreator,
      );

      _players.add(player);
    }

    return copyWith(players: _players.toList());
  }
}
