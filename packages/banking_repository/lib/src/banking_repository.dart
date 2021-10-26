import 'dart:developer';
import 'dart:math' hide log;

import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

import 'models/models.dart';

enum JoinGameResult {
  none,
  success,
  noConnection,
  gameNotFound,
  tooManyPlayers,
  hasAlreadyStarted,
  failure
}

enum MakeTransactionResult { none, success, failure }

class BankingRepository {
  BankingRepository({
    required this.useFirebaseEmulator,
    required this.userRepository,
  }) {
    if (useFirebaseEmulator) {
      _firebaseFirestore.useFirestoreEmulator('localhost', 8080);
    }
  }

  final bool useFirebaseEmulator;
  final UserRepository userRepository;

  // #### Firebase Collection references:
  static final _firebaseFirestore = FirebaseFirestore.instance;

  final _gamesCollection =
      _firebaseFirestore.collection('games').withConverter<Game>(
            fromFirestore: (snap, _) => Game.fromSnapshot(snap),
            toFirestore: (model, _) => model.toDocument(),
          );

  // ### Constants:
  static const maxPlayersPerGame = 6;

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
          _addGameResult(gameId: game.id);
        }

        return game;
      },
    );
  }

  /// Joins the game with the given id.
  ///
  /// If successful this updates the users currentGameId in the database.
  Future<JoinGameResult> joinGame(String gameId) async {
    gameId = gameId.toUpperCase();

    try {
      final gameSnapshot = await _gamesCollection.doc(gameId).get();

      if (!gameSnapshot.exists) return JoinGameResult.gameNotFound;

      final game = gameSnapshot.data()!;

      final containsPlayer = game.containsPlayerWithId(userRepository.user.id);

      if (!containsPlayer) {
        if (game.hasStarted) {
          return JoinGameResult.hasAlreadyStarted;
        }

        if (game.players.size >= maxPlayersPerGame) {
          return JoinGameResult.tooManyPlayers;
        }
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

  /// Quits the game (goes bankrupt), calls [_addGameResult()] if the game has a winner and sets the users currentGameId to null.
  ///
  /// On top of that it also deletes the game if there is no other player in the game.
  Future<void> quitGame(String gameId) async {
    final gameSnapshot = await _gamesCollection.doc(gameId).get();

    if (gameSnapshot.exists && gameSnapshot.data() != null) {
      final game = gameSnapshot.data()!;

      if (game.containsPlayerWithId(userRepository.user.id)) {
        if (game.players.size == 1) {
          await _gamesCollection.doc(gameId).delete();
        } else if (!game.hasWinner) {
          final player = game.getPlayer(userRepository.user.id);

          if (!player.isBankrupt) {
            // Make player bankrupt by transferring all his money to the bank.
            await makeTransaction(
              gameId: game.id,
              transactionType: TransactionType.toBank,
              amount: player.balance,
            );

            final updatedGame =
                (await _gamesCollection.doc(gameId).get()).data()!;

            if (updatedGame.hasWinner) {
              await _addGameResult(gameId: gameId);
            }
          }
        } else if (game.hasWinner) {
          await _addGameResult(gameId: gameId);
        }
      }
    }

    await userRepository.setCurrentGameId(null);
  }

  /// Creates a new game and returns its id if successful.
  ///
  /// Also updates the users currentGameId in the database if successful.
  Future<String?> createNewGameAndJoin({
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

      return game.id;
    } catch (e) {
      log('Unknown exception in createNewGameAndJoin(): $e');

      return null;
    }
  }

  /// Gets a random game id until it is unique.
  // todo: Check how many game ids can be created until there are no new combinations anymore.
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
    await _gamesCollection
        .doc(game.id)
        .update({'startingTimestamp': FieldValue.serverTimestamp()});
  }

  /// Transfers money.
  Future<MakeTransactionResult> makeTransaction({
    required String gameId,
    required TransactionType transactionType,
    int? amount,
    String? toUserId,
  }) async {
    try {
      final networkTime = await getNetworkTime();

      final game = (await _gamesCollection.doc(gameId).get()).data()!;

      late final Transaction transaction;
      switch (transactionType) {
        case TransactionType.fromBank:
          assert(amount != null);
          transaction = Transaction.fromBank(
              toUserId: userRepository.user.id,
              amount: amount!,
              timestamp: networkTime);
          break;
        case TransactionType.toBank:
          assert(amount != null);
          transaction = Transaction.toBank(
              fromUserId: userRepository.user.id,
              amount: amount!,
              timestamp: networkTime);
          break;
        case TransactionType.toPlayer:
          assert(toUserId != null);
          assert(amount != null);
          transaction = Transaction.toPlayer(
              fromUserId: userRepository.user.id,
              toUserId: toUserId!,
              amount: amount!,
              timestamp: networkTime);
          break;
        case TransactionType.toFreeParking:
          assert(amount != null);
          transaction = Transaction.toFreeParking(
              fromUserId: userRepository.user.id,
              amount: amount!,
              timestamp: networkTime);
          break;
        case TransactionType.fromFreeParking:
          transaction = Transaction.fromFreeParking(
              toUserId: userRepository.user.id,
              freeParkingMoney: game.freeParkingMoney,
              timestamp: networkTime);
          break;
        case TransactionType.fromSalary:
          transaction = Transaction.fromSalary(
              toUserId: userRepository.user.id,
              salary: game.salary,
              timestamp: networkTime);
          break;
      }

      final updatedGame = await game.makeTransaction(transaction);

      await _gamesCollection.doc(game.id).set(updatedGame);

      return MakeTransactionResult.success;
    } catch (e) {
      log('Unknown exception in makeTransaction(): $e');

      return MakeTransactionResult.failure;
    }
  }

  /// Creates a [GameResult] object from the game and adds it to the users playedGameResults list IF it isn't already!
  ///
  /// Only call this if the game already has a winner!
  Future<void> _addGameResult({required String gameId}) async {
    final game = (await _gamesCollection.doc(gameId).get()).data()!;

    assert(game.hasWinner);

    final alreadyAdded =
        userRepository.user.playedGameResultsContainsGameWithId(gameId);

    if (!alreadyAdded) {
      final gameResult = game.toGameResult();

      await userRepository.addGameResult(gameResult);
    }
  }
}
