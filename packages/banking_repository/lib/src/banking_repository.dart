import 'dart:developer';
import 'dart:math' hide log;

import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:deep_pick/deep_pick.dart';
import 'package:ntp/ntp.dart';
import 'package:user_repository/user_repository.dart';

import 'models/models.dart';

enum CreateNewGameResult { none, success, noConnection, failure }

enum JoinGameResult {
  none,
  success,
  noConnection,
  gameNotFound,
  tooManyPlayers,
  hasAlreadyStarted,
  failure
}

class BankingRepository {
  BankingRepository({required this.userRepository});
  final UserRepository userRepository;

  // #### Firebase Collection references:
  final _gamesCollection =
      FirebaseFirestore.instance.collection('games').withConverter<Game>(
            fromFirestore: (snap, _) => Game.fromSnapshot(snap),
            toFirestore: (model, _) => model.toDocument(),
          );

  // #### Public methods:

  /// Streams the game with the given id.
  Stream<Game?> streamGame(String currentGameId) {
    return _gamesCollection
        .doc(currentGameId)
        .snapshots(includeMetadataChanges: true)
        .map(
      (doc) {
        final game = doc.data();

        if (game != null && game.hasWinner) {
          updateStats(game);
        }

        return game;
      },
    );
  }

  /// Disconnects from any game.
  Future<void> leaveGame() async {
    await userRepository.setCurrentGameId(null);
  }

  Future<JoinGameResult> joinGame(String gameId) async {
    gameId = gameId.toUpperCase();

    try {
      final gameSnapshot = await _gamesCollection.doc(gameId).get();

      if (!gameSnapshot.exists) return JoinGameResult.gameNotFound;

      final game = gameSnapshot.data()!;

      final wasAlreadyConnectedToGame = game.players
          .asList()
          .where((player) => player.userId == userRepository.user.id)
          .isNotEmpty;

      // Only allow a connection when the game is not started or the player was already connected to the game.
      if (game.hasStarted && !wasAlreadyConnectedToGame) {
        return JoinGameResult.hasAlreadyStarted;
      }

      if (game.players.size >= 6 && !wasAlreadyConnectedToGame) {
        return JoinGameResult.tooManyPlayers;
      }

      // Join the game:
      final updatedGame = game.addPlayer(userRepository.user);
      await _gamesCollection.doc(game.id).set(updatedGame);
      await userRepository.setCurrentGameId(game.id);

      return JoinGameResult.success;
    } on FirebaseException catch (e) {
      log('FirebaseException in joinGame(): $e');

      switch (e.code) {
        case 'unavailable':
          return JoinGameResult.noConnection;
        default:
          return JoinGameResult.failure;
      }
    } catch (e) {
      log('Unknown exception in joinGame(): $e');

      return JoinGameResult.failure;
    }
  }

  /// Creates a new game lobby and returns itself.
  Future<CreateNewGameResult> createNewGameAndJoin({
    required int startingCapital,
    required int salary,
    required bool enableFreeParkingMoney,
  }) async {
    try {
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

      // Join the game:
      final updatedGame =
          game.addPlayer(userRepository.user, isGameCreator: true);
      await _gamesCollection.doc(game.id).set(updatedGame);
      await userRepository.setCurrentGameId(game.id);

      return CreateNewGameResult.success;
    } on FirebaseException catch (e) {
      log('FirebaseException in createNewGameAndJoin(): $e');

      switch (e.code) {
        case 'unavailable':
          return CreateNewGameResult.noConnection;
        default:
          return CreateNewGameResult.failure;
      }
    } catch (e) {
      log('Unknown exception in createNewGameAndJoin(): $e');

      return CreateNewGameResult.failure;
    }
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

  /// Sets the starting timestamp to the current server time which starts the game.
  Future<void> startGame(Game game) async {
    await FirebaseFirestore.instance
        .collection('games')
        .doc(game.id)
        .update({'startingTimestamp': FieldValue.serverTimestamp()});
  }

  /// Transfers money.
  Future<void> makeTransaction({
    required Game game,
    required TransactionType transactionType,
    int? amount,
    String? toUserId,
  }) async {
    // todo: Find a better solution for this
    // When using the web app and cellular network running NTP.now() fails.
    // This ist just a temporary fix:
    var timestamp = DateTime.now();
    try {
      timestamp = await NTP.now();
    } catch (_) {}

    late final Transaction transaction;
    switch (transactionType) {
      case TransactionType.fromBank:
        assert(amount != null);
        transaction = Transaction.fromBank(
            toUserId: userRepository.user.id,
            amount: amount!,
            timestamp: timestamp);
        break;
      case TransactionType.toBank:
        assert(amount != null);
        transaction = Transaction.toBank(
            fromUserId: userRepository.user.id,
            amount: amount!,
            timestamp: timestamp);
        break;
      case TransactionType.toPlayer:
        assert(toUserId != null);
        assert(amount != null);
        transaction = Transaction.toPlayer(
            fromUserId: userRepository.user.id,
            toUserId: toUserId!,
            amount: amount!,
            timestamp: timestamp);
        break;
      case TransactionType.toFreeParking:
        assert(amount != null);
        transaction = Transaction.toFreeParking(
            fromUserId: userRepository.user.id,
            amount: amount!,
            timestamp: timestamp);
        break;
      case TransactionType.fromFreeParking:
        transaction = Transaction.fromFreeParking(
            toUserId: userRepository.user.id,
            freeParkingMoney: game.freeParkingMoney,
            timestamp: timestamp);
        break;
      case TransactionType.fromSalary:
        transaction = Transaction.fromSalary(
            toUserId: userRepository.user.id,
            salary: game.salary,
            timestamp: timestamp);
        break;
    }

    final updatedGame = await game.makeTransaction(transaction);

    await _gamesCollection.doc(game.id).set(updatedGame);

    /* // ### Update stats of players if necessary:

    final currentUserIsBankruptNow =
        updatedGame.getPlayer(userRepository.user.id).isBankrupt;

    if (currentUserIsBankruptNow) {
      await userRepository.incrementGamesPlayed();
    }

    final otherUserIsWinnerNow = toUserId != null && updatedGame.winner != null
        ? updatedGame.winner!.userId == toUserId
        : false;

    if (otherUserIsWinnerNow) {
      assert(updatedGame.winner != null);

      await userRepository.incrementGamesWon(updatedGame.winner!.userId);
    }*/
  }

  /// Update the users stats if they are not already.s
  Future<void> updateStats(Game game) async {
    assert(game.hasWinner);

    final alreadyUpdated = userRepository.user.playedGamesIds.contains(game.id);

    if (!alreadyUpdated) {
      if (game.winner!.userId == userRepository.user.id) {
        await userRepository.incrementGamesWon();
      }

      await userRepository.addGameId(game.id);
    }
  }
}

extension TimestampPick on Pick {
  Timestamp asFirestoreTimeStampOrThrow() {
    final value = required().value;
    if (value is Timestamp) {
      return value;
    }
    if (value is int) {
      return Timestamp.fromMillisecondsSinceEpoch(value);
    }
    throw PickException(
        "value $value at $debugParsingExit can't be casted to Timestamp");
  }

  Timestamp? asFirestoreTimeStampOrNull() {
    if (value == null) return null;
    try {
      return asFirestoreTimeStampOrThrow();
    } catch (_) {
      return null;
    }
  }
}
