part of 'join_game_cubit.dart';

class JoinGameState extends Equatable {
  const JoinGameState({
    this.isSubmitting = false,
    this.gameId = '',
    this.joinGameResult = JoinGameResult.none,
  });

  final bool isSubmitting;
  final String gameId;
  final JoinGameResult joinGameResult;

  @override
  List<Object> get props => [
        isSubmitting,
        gameId,
        joinGameResult,
      ];

  JoinGameState copyWith({
    bool? isSubmitting,
    String? gameId,
    JoinGameResult? joinGameResult,
  }) {
    return JoinGameState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      gameId: gameId ?? this.gameId,
      joinGameResult: joinGameResult ?? this.joinGameResult,
    );
  }
}
