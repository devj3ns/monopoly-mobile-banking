import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:user_repository/user_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const LoginState());

  final UserRepository _userRepository;

  void resetSignInResult() {
    emit(state.copyWith(signInResult: SignInResult.none));
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(isSubmitting: true));

    final result = await _userRepository.signInWithGoogle();

    emit(state.copyWith(isSubmitting: false, signInResult: result));
  }

  Future<void> signInAnonymously() async {
    emit(state.copyWith(isSubmitting: true));

    final result = await _userRepository.signInAnonymously();

    emit(state.copyWith(isSubmitting: false, signInResult: result));
  }
}
