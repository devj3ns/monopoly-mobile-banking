import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:banking_repository/banking_repository.dart';

part 'join_game_state.dart';

class JoinGameCubit extends Cubit<JoinGameState> {
  JoinGameCubit({required BankingRepository bankingRepository})
      : _bankingRepository = bankingRepository,
        super(const JoinGameState());

  final BankingRepository _bankingRepository;

  void gameIdChanged(String gameId) {
    emit(state.copyWith(gameId: gameId));
  }

  Future<void> onFormSubmitted() async {
    assert(state.gameId.isNotEmpty);

    emit(state.copyWith(isSubmitting: true));

    final result = await _bankingRepository.joinGame(state.gameId);

    emit(state.copyWith(isSubmitting: false, joinGameResult: result));
  }

  void resetJoinGameResult() {
    emit(state.copyWith(joinGameResult: JoinGameResult.none));
  }
}
