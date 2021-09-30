part of 'create_game_cubit.dart';

class CreateGameState extends Equatable {
  const CreateGameState({
    this.isSubmitting = false,
    this.enableFreeParkingMoney = false,
    this.salary = 200,
    this.startingCapital = 1500,
    this.gameId,
    this.joiningFailed = false,
  });

  final bool isSubmitting;
  final bool enableFreeParkingMoney;
  final int salary;
  final int startingCapital;
  final String? gameId;
  final bool joiningFailed;

  @override
  List<Object?> get props => [
        isSubmitting,
        enableFreeParkingMoney,
        salary,
        startingCapital,
        gameId,
        joiningFailed,
      ];

  CreateGameState copyWith({
    bool? isSubmitting,
    bool? enableFreeParkingMoney,
    int? salary,
    int? startingCapital,
    String? Function()? gameId,
    bool? joiningFailed,
  }) {
    return CreateGameState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      enableFreeParkingMoney:
          enableFreeParkingMoney ?? this.enableFreeParkingMoney,
      salary: salary ?? this.salary,
      startingCapital: startingCapital ?? this.startingCapital,
      gameId: gameId != null ? gameId() : this.gameId,
      joiningFailed: joiningFailed ?? this.joiningFailed,
    );
  }
}
