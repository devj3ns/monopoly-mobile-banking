import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// Streams all games.
  Stream<List<Game>> get allGames {
    return _gamesCollection
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

  /// Creates a new game lobby.
  Future<void> newGame() async {
    await _gamesCollection.add(Game.empty());
  }

  /// Transfers money from one player to another.
  ///
  /// If fromUser is null, the money comes from the bank.
  /// If toUser is null, the money goes to the bank.
  Future<void> makeTransaction({
    required Game game,
    User? fromUser,
    User? toUser,
    required int amount,
  }) async {
    final updatedGame = game.makeTransaction(
        fromUser: fromUser, toUser: toUser, amount: amount);

    await _gamesCollection.doc(game.id).set(updatedGame);

    //todo: update timestamp to server timestamp!
  }
}
