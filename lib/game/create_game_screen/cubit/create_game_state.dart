part of 'create_game_cubit.dart';

class CreateGameState extends Equatable {
  const CreateGameState({
    this.isSubmitting = false,
    this.enableFreeParkingMoney = false,
    this.salary = 200,
    this.startingCapital = 1500,
    this.createNewGameResult = CreateNewGameResult.none,
  });

  final bool isSubmitting;
  final bool enableFreeParkingMoney;
  final int salary;
  final int startingCapital;
  final CreateNewGameResult createNewGameResult;

  @override
  List<Object> get props => [
        isSubmitting,
        enableFreeParkingMoney,
        salary,
        startingCapital,
        createNewGameResult,
      ];

  CreateGameState copyWith({
    bool? isSubmitting,
    bool? enableFreeParkingMoney,
    int? salary,
    int? startingCapital,
    CreateNewGameResult? createNewGameResult,
  }) {
    return CreateGameState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      enableFreeParkingMoney:
          enableFreeParkingMoney ?? this.enableFreeParkingMoney,
      salary: salary ?? this.salary,
      startingCapital: startingCapital ?? this.startingCapital,
      createNewGameResult: createNewGameResult ?? this.createNewGameResult,
    );
  }
}
