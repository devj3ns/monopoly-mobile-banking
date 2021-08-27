import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:banking_repository/banking_repository.dart';

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

  Future<void> onFormSubmitted() async {
    emit(state.copyWith(isSubmitting: true));

    final result = await _bankingRepository.createNewGameAndJoin(
      enableFreeParkingMoney: state.enableFreeParkingMoney,
      salary: state.salary,
      startingCapital: state.startingCapital,
    );

    emit(state.copyWith(isSubmitting: false, createNewGameResult: result));
  }

  void resetCreateGameResult() {
    emit(state.copyWith(createNewGameResult: CreateNewGameResult.none));
  }
}
