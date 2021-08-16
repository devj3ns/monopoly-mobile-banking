import 'package:kt_dart/kt.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:user_repository/user_repository.dart';

import '../../banking_repository.dart';
import 'player.dart';

class Game extends Equatable {
  const Game({
    required this.id,
    required this.players,
    required this.transactions,
  });

  /// The unique id of the game.
  final String id;

  /// The players connected to this game, sorted by balance.
  final KtList<Player> players;

  /// The transaction history of this game, sorted by timestamp.
  final KtList<Transaction> transactions;

  @override
  List<Object> get props => [id, players, transactions];

  static int startBalance = 5000;

  static Game empty() {
    return const Game(
      id: '',
      players: KtList<Player>.empty(),
      transactions: KtList<Transaction>.empty(),
    );
  }

  static Game fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data()!;

    final _players =
        ((List<Map<String, dynamic>>.from(data['players'] as List<dynamic>))
                .map(Player.fromJson)
                .toList()
                  ..sort((a, b) => b.balance.compareTo(a.balance)))
            .toImmutableList();

    final _transactions = ((List<Map<String, dynamic>>.from(
                data['transactions'] as List<dynamic>))
            .map(Transaction.fromJson)
            .toList()
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp)))
        .toImmutableList();

    return Game(
      id: snap.id,
      players: _players,
      transactions: _transactions,
    );
  }

  Map<String, Object> toDocument() {
    return {
      'players': players.isEmpty()
          ? <Player>[]
          : players.map((player) => player.toJson()).asList(),
      'transactions': transactions.isEmpty()
          ? <Transaction>[]
          : transactions.map((transaction) => transaction.toJson()).asList(),
    };
  }

  Game copyWith({KtList<Player>? players, KtList<Transaction>? transactions}) {
    return Game(
      id: id,
      players: players ?? this.players,
      transactions: transactions ?? this.transactions,
    );
  }

  /// Whether the user was already connected to this game.
  bool containsUser(String userId) {
    return players.indexOfFirst((player) => player.userId == userId) != -1;
  }

  /// Returns the player with the given id.
  Player getPlayer(String userId) {
    assert(containsUser(userId));

    return players[players.indexOfFirst((player) => player.userId == userId)];
  }

  /// Returns all players except of the one with the given id, sorted by balance.
  List<Player> otherPlayers(String userId) {
    return players.asList().where((player) => player.userId != userId).toList();
  }

  /// Returns a new instance which represents the game after the transaction.
  ///
  /// If fromUser is null, the money comes from the bank.
  /// If toUser is null, the money goes to the bank.
  Game _makeTransaction({
    User? fromUser,
    User? toUser,
    required int amount,
  }) {
    assert(fromUser != null || toUser != null);

    // Create new/updated players list:
    final _players = players.toMutableList().asList();

    if (fromUser != null) {
      // Subtract money from the player:
      final fromPlayerIndex =
          _players.indexWhere((player) => player.userId == fromUser.id);
      _players[fromPlayerIndex] =
          _players[fromPlayerIndex].subtractMoney(amount);
    }

    if (toUser != null) {
      // Add money to the other player:
      final toPlayerIndex =
          _players.indexWhere((player) => player.userId == toUser.id);
      _players[toPlayerIndex] = _players[toPlayerIndex].addMoney(amount);
    }

    // Create new/updated transactions list:
    final _transactions = transactions.toMutableList().asList();

    final transaction = Transaction(
      fromUser: fromUser,
      toUser: toUser,
      amount: amount,
      // This gets replaced with the server time later:
      timestamp: DateTime.now(),
    );

    _transactions.add(transaction);

    return copyWith(
        players: _players.toImmutableList(),
        transactions: _transactions.toImmutableList());
  }

  // ### Database functions:
  /// Returns the DocumentReference of this game in the database.
  DocumentReference<Game> get databaseDoc => FirebaseFirestore.instance
      .collection('games')
      .doc(id)
      .withConverter<Game>(
        fromFirestore: (snap, _) => fromSnapshot(snap),
        toFirestore: (model, _) => model.toDocument(),
      );

  /// Transfers money from one player to another.
  ///
  /// If fromUser is null, the money comes from the bank.
  /// If toUser is null, the money goes to the bank.
  Future<void> makeTransaction({
    User? fromUser,
    User? toUser,
    required int amount,
  }) async {
    final updatedGame =
        _makeTransaction(fromUser: fromUser, toUser: toUser, amount: amount);

    await databaseDoc.set(updatedGame);

    //todo: update timestamp to server timestamp!
  }

  /// Connects the player to the game and sets his start balance.
  Future<void> join(User user) async {
    final _players = players.toMutableList();

    if (!containsUser(user.id)) {
      _players
          .add(Player(userId: user.id, name: user.name, balance: startBalance));
    }

    final updatedGame = copyWith(players: _players.toList());

    await databaseDoc.set(updatedGame);

    await BankingRepository(userId: user.id).joinGame(this);
  }

  /// Creates a new game lobby.
  static Future<void> newOne() async {
    await FirebaseFirestore.instance
        .collection('games')
        .add(Game.empty().toDocument());
  }
}
