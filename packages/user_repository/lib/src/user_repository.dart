import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/models.dart';

class UserRepository {
  const UserRepository({required this.userId});
  final String userId;

  // #### Firebase instances:
  static final _firebaseFirestore = FirebaseFirestore.instance;

  // #### Collection references:
  static CollectionReference<User> get _usersCollection =>
      _firebaseFirestore.collection('users').withConverter<User>(
            fromFirestore: (snap, _) => User.fromSnapshot(snap),
            toFirestore: (model, _) => model.toDocument(),
          );

  static CollectionReference<Game> get _gamesCollection =>
      _firebaseFirestore.collection('games').withConverter<Game>(
            fromFirestore: (snap, _) => Game.fromSnapshot(snap),
            toFirestore: (model, _) => model.toDocument(),
          );

  // #### Public methods:
  /// Streams the users data from the database.
  Stream<User> streamUserData() {
    return _usersCollection.doc(userId).snapshots().map((user) => user.data()!);
  }

  /// Creates an user object in the database.
  static Future<void> createUser({
    required String name,
    required String authId,
  }) async {
    await _usersCollection
        .doc(authId)
        .set(User(id: authId, name: name));
  }

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
