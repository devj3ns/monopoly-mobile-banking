import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

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

    final game = await _bankingRepository.newGame(
      enableFreeParkingMoney: state.enableFreeParkingMoney,
      salary: state.salary,
      startingCapital: state.startingCapital,
    );

    await _bankingRepository.joinGame(game);

    emit(state.copyWith(isSubmitting: false));
  }
}
