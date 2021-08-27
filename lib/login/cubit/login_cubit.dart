import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';
import 'package:fleasy/fleasy.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const LoginState());

  final UserRepository _userRepository;

  void onUsernameChanged(String username) {
    emit(state.copyWith(username: username));
  }

  void resetSignInResult() {
    emit(state.copyWith(signInResult: SignInResult.none));
  }

  Future<void> signIn() async {
    assert(state.username.isNotBlank);

    emit(state.copyWith(isSubmitting: true));

    final result = await _userRepository.signIn(state.username);

    emit(state.copyWith(isSubmitting: false, signInResult: result));
  }
}
