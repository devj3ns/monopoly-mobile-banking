import 'package:banking_repository/banking_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'create_game_state.dart';

class CreateGameCubit extends Cubit<CreateGameState> {
  CreateGameCubit({required BankingRepository bankingRepository})
      : _bankingRepository = bankingRepository,
        super(const CreateGameState());

  final BankingRepository _bankingRepository;

  void onEnableFreeParkingMoneyChanged(bool enableFreeParkingMoney) {
    emit(state.copyWith(enableFreeParkingMoney: enableFreeParkingMoney));
  }

  void onSalaryChanged(int salary) {
    emit(state.copyWith(salary: salary));
  }

  void onStartingCapitalChanged(int startingCapital) {
    emit(state.copyWith(startingCapital: startingCapital));
  }

  void resetJoiningFailed() {
    emit(state.copyWith(joiningFailed: false));
  }

  void onFormSubmitted() async {
    emit(state.copyWith(isSubmitting: true, joiningFailed: false));

    final gameId = await _bankingRepository.createNewGameAndJoin(
      enableFreeParkingMoney: state.enableFreeParkingMoney,
      salary: state.salary,
      startingCapital: state.startingCapital,
    );

    emit(state.copyWith(
      isSubmitting: false,
      gameId: () => gameId,
      joiningFailed: gameId == null ? true : false,
    ));
  }
}
