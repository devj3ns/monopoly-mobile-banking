import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';
import 'package:fleasy/fleasy.dart';

part 'choose_username_state.dart';

class ChooseUsernameCubit extends Cubit<ChooseUsernameState> {
  ChooseUsernameCubit({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const ChooseUsernameState());

  final UserRepository _userRepository;

  void onUsernameChanged(String username) {
    emit(state.copyWith(username: username));
  }

  void resetSignInResult() {
    emit(state.copyWith(chooseUsernameResult: ChooseUsernameResult.none));
  }

  Future<void> submitForm() async {
    assert(state.username.isNotBlank);

    emit(state.copyWith(isSubmitting: true));

    final result = await _userRepository.chooseUsername(state.username);

    emit(state.copyWith(isSubmitting: false, chooseUsernameResult: result));
  }
}
