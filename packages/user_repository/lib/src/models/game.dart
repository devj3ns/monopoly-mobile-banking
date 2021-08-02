import 'package:kt_dart/kt.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:user_repository/user_repository.dart';

import 'player.dart';

class Game extends Equatable {
  const Game({
    required this.id,
    required this.players,
  });

  /// The unique id of the game.
  final String id;

  /// The players and their balance in this game.
  final KtList<Player> players;

  @override
  List<Object> get props => [id, players];

  static int startBalance = 100000;

  static Game fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data()!;

    return Game(
      id: snap.id,
      players:
          (List<Map<String, dynamic>>.from(data['players'] as List<dynamic>))
              .map(Player.fromJson)
              .toImmutableList(),
    );
  }

  Map<String, Object> toDocument() {
    return {
      'players': players.isEmpty()
          ? <Player>[]
          : players.map((player) => player.toJson()).asList(),
    };
  }

  Game copyWith({KtList<Player>? players}) {
    return Game(
      id: id,
      players: players ?? this.players,
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

  /// Returns all players except of the one with the given id.
  List<Player> otherPlayers(String userId) {
    return players.asList().where((player) => player.userId != userId).toList();
  }

  /// Returns a new instance which represents the game after the transaction.
  Game _makeTransaction({
    required String fromUserId,
    required String toUserId,
    required int amount,
  }) {
    final _players = players.toMutableList().asList();

    final fromPlayerIndex =
        _players.indexWhere((player) => player.userId == fromUserId);
    _players[fromPlayerIndex] = _players[fromPlayerIndex].subtractMoney(amount);

    final toPlayerIndex =
        _players.indexWhere((player) => player.userId == toUserId);
    _players[toPlayerIndex] = _players[toPlayerIndex].addMoney(amount);

    return copyWith(players: _players.toImmutableList());
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
  Future<void> makeTransaction({
    required String fromUserId,
    required String toUserId,
    required int amount,
  }) async {
    final updatedGame = _makeTransaction(
        fromUserId: fromUserId, toUserId: toUserId, amount: amount);

    await databaseDoc.set(updatedGame);
  }

  /// Connects the player to the game and sets his start balance.
  Future<void> join(User user) async {
    final _players = players.toMutableList();

    if (!containsUser(user.id)) {
      _players.add(
          Player(userId: user.id, name: user.name, balance: startBalance));
    }

    final updatedGame = copyWith(players: _players.toList());

    await databaseDoc.set(updatedGame);

    await UserRepository(userId: user.id).joinGame(this);
  }

  /// Creates a new game lobby.
  static Future<void> newOne() async {
    final newGame = Game(players: <Player>[].toImmutableList(), id: '');

    await FirebaseFirestore.instance
        .collection('games')
        .add(newGame.toDocument());
  }
}
