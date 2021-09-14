import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fleasy/fleasy.dart';

import 'package:user_repository/user_repository.dart';

part 'set_username_state.dart';

class SetUsernameCubit extends Cubit<SetUsernameState> {
  SetUsernameCubit({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const SetUsernameState());

  final UserRepository _userRepository;

  void onUsernameChanged(String username) {
    emit(state.copyWith(username: username));
  }

  void resetSignInResult() {
    emit(state.copyWith(chooseUsernameResult: SetUsernameResult.none));
  }

  Future<void> submitForm() async {
    assert(state.username.isNotBlank);

    emit(state.copyWith(isSubmitting: true));

    final result = await _userRepository.setUsername(state.username);

    emit(state.copyWith(isSubmitting: false, chooseUsernameResult: result));
  }
}
