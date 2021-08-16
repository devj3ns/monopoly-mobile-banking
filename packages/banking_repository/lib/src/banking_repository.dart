import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/models.dart';

class BankingRepository {
  const BankingRepository({required this.userId});
  final String userId;

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
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'currentGameId': null});
  }

  /// Joins to the given game.
  Future<void> joinGame(Game game) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'currentGameId': game.id});
  }
}
