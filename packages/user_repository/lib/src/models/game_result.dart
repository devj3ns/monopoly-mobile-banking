import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/src/user_repository.dart';

/// The summarized result of a game.
class GameResult extends Equatable {
  const GameResult({
    required this.gameId,
    required this.winnerId,
    required this.startingTimestamp,
    required this.duration,
    required this.places,
  });

  /// The id of the game this result is created from.
  final String gameId;

  /// The user id of the user who won the game.
  final String winnerId;

  /// The date and time the game was started.
  final DateTime startingTimestamp;

  /// The duration of the game.
  final Duration duration;

  /// The users places.
  ///
  /// e.g.:
  /// {'Jens': 1, 'Eve': 2}
  final Map<String, int> places;

  @override
  List<Object> get props => [
        gameId,
        winnerId,
        startingTimestamp,
        duration,
        places,
      ];

  static GameResult fromJson(Map<String, dynamic> json) => GameResult(
        gameId: pick(json, 'gameId').asStringOrThrow(),
        winnerId: pick(json, 'winnerId').asStringOrThrow(),
        startingTimestamp: pick(json, 'startingTimestamp')
            .asFirestoreTimeStampOrThrow()
            .toDate(),
        duration:
            Duration(seconds: pick(json, 'durationInSeconds').asIntOrThrow()),
        places: pick(json, 'places').asMapOrThrow<String, int>(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'gameId': gameId,
        'winnerId': winnerId,
        'startingTimestamp': startingTimestamp,
        'durationInSeconds': duration.inSeconds,
        'places': places,
      };
}
