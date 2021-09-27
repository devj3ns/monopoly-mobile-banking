import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:fleasy/fleasy.dart';
import 'package:user_repository/src/models/game_result.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.playedGameResults,
    this.photoURL,
    this.currentGameId,
  }) : assert(currentGameId != '');

  /// The unique id of the user (from Firebase Auth).
  final String id;

  /// The username the users chose (This name can change over the time!).
  final String name;

  /// A list with results of all games the player played and finished.
  ///
  /// A game result gets added when a game has a winner.
  final List<GameResult> playedGameResults;

  /// The Google photo url (only if authenticated with Google).
  final String? photoURL;

  /// The id of the game the user is currently connected to.
  final String? currentGameId;

  /// How many games the user won.
  int get gamesWon =>
      playedGameResults.where((gameResult) => gameResult.winnerId == id).length;

  /// How many games the player player played and finished.
  int get gamesPlayed => playedGameResults.length;

  /// Whether the user has a [GameResult] with the given id in his [playedGameResults] list.
  ///
  /// This is usually the case if the user finished the game (bankrupt or won it).
  bool playedGameResultsContainsGameWithId(String gameId) => playedGameResults
      .where((gameResult) => gameResult.gameId == gameId)
      .isNotEmpty;

  static const none = User(
    id: '',
    name: '',
    playedGameResults: [],
    photoURL: null,
    currentGameId: null,
  );

  @override
  List<Object?> get props => [
        id,
        name,
        playedGameResults,
        photoURL,
        currentGameId,
      ];

  static User fromJson(
    Map<String, dynamic> json, {
    required String snapshotId,
  }) =>
      User(
        id: snapshotId,
        name: pick(json, 'name').asStringOrThrow(),
        playedGameResults: pick(json, 'playedGameResults').asListOrThrow(
            (gameResult) =>
                GameResult.fromJson(gameResult.asMapOrThrow<String, dynamic>()))
          ..sort((a, b) => b.startingTimestamp.compareTo(a.startingTimestamp)),
        photoURL: pick(json, 'photoURL').asStringOrNull(),
        currentGameId: pick(json, 'currentGameId').asStringOrNull(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'playedGameResults': playedGameResults.isEmpty
            ? <GameResult>[]
            : playedGameResults
                .map((gameResult) => gameResult.toJson())
                .toList(),
        'photoURL': photoURL,
        'currentGameId': currentGameId,
      };

  User copyWith({
    String? id,
    String? name,
    List<GameResult>? playedGameResults,
    String? photoURL,
    String? Function()? currentGameId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      playedGameResults: playedGameResults ?? this.playedGameResults,
      photoURL: photoURL ?? this.photoURL,
      currentGameId:
          currentGameId != null ? currentGameId() : this.currentGameId,
    );
  }
}

extension UserExtensions on User {
  bool get isNone => this == User.none;

  bool get hasUsername => name.isNotBlank;
}
