import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:user_repository/user_repository.dart';

import 'models/models.dart';

class BankingRepository {
  const BankingRepository({required this.userRepository});
  final UserRepository userRepository;

  // #### Firebase instances:
  static final _firebaseFirestore = FirebaseFirestore.instance;

  // #### Collection references:
  static CollectionReference<Game> get _gamesCollection =>
      _firebaseFirestore.collection('games').withConverter<Game>(
            fromFirestore: (snap, _) => Game.fromSnapshot(snap),
            toFirestore: (model, _) => model.toDocument(),
          );

  // #### Public methods:

  /// Streams a list of all active games (all games where nobody won yet).
  Stream<List<Game>> get allActiveGames {
    return _gamesCollection
        .where('winnerId', isNull: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((game) => game.data()).toList());
  }

  /// Streams the game with the given id.
  Stream<Game?> streamGame(String currentGameId) {
    return _gamesCollection
        .doc(currentGameId)
        .snapshots()
        .map((doc) => doc.data());
  }

  /// Disconnects from any game.
  Future<void> leaveGame() async {
    await userRepository.setCurrentGameId(null);
  }

  /// Joins to the given game.
  Future<void> joinGame(Game game) async {
    final updatedGame = game.addPlayer(userRepository.user);
    await _gamesCollection.doc(game.id).set(updatedGame);

    await userRepository.setCurrentGameId(game.id);
  }

  /// Creates a new game lobby and returns itself.
  Future<Game> newGame({
    required int startingCapital,
    required int salary,
    required bool enableFreeParkingMoney,
  }) async {
    final gameId = await _uniqueGameId();

    assert(!(await _gamesCollection.doc(gameId).get()).exists);

    await _gamesCollection.doc(gameId).set(
          Game.newOne(
            id: _randomGameId(),
            startingCapital: startingCapital,
            salary: salary,
            enableFreeParkingMoney: enableFreeParkingMoney,
          ),
        );

    final game = (await _gamesCollection.doc(gameId).get()).data()!;

    return game;
  }

  /// Gets a random game id until it is unique.
  // todo: avoid waiting forever when all ids are taken.
  Future<String> _uniqueGameId() async {
    final id = _randomGameId();

    while ((await _gamesCollection.doc(id).get()).exists) {
      return _uniqueGameId();
    }

    return id;
  }

  /// Generates a random game id.
  String _randomGameId() {
    const length = 4;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    return List.generate(
      length,
      (index) => chars[Random.secure().nextInt(chars.length)],
    ).join('');
  }

  /// Transfers money from one player to another.
  ///
  /// Use custom constructors for the transaction object:
  /// For example Transaction.fromBank(...) or Transaction.toPlayer(...).
  Future<void> makeTransaction({
    required Game game,
    required Transaction transaction,
  }) async {
    final updatedGame = game.makeTransaction(transaction);

    //todo: update timestamp to server timestamp!
    await _gamesCollection.doc(game.id).set(updatedGame);

    await checkIfGameIsOver(updatedGame);
  }

  /// Increments the win field of a user in firestore.
  Future<void> _incrementWinsOfUser(String userId) async {
    await _firebaseFirestore
        .collection('users')
        .doc(userId)
        .update({'wins': FieldValue.increment(1)});
  }

  /// Checks whether there is only one player left who is not bankrupt.
  /// If that's the case the winnerId of the game is set.
  Future<void> checkIfGameIsOver(Game game) async {
    if (game.nonBankruptPlayers.size == 1 && game.players.size > 1) {
      final winner = game.nonBankruptPlayers[0];

      await _gamesCollection
          .doc(game.id)
          .set(game.copyWith(winnerId: winner.userId));

      await _incrementWinsOfUser(winner.userId);
    }
  }
}
