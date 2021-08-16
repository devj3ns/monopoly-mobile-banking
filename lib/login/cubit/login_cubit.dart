import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';
import 'package:fleasy/fleasy.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const LoginState());

  final UserRepository _userRepository;

  Future<void> signIn() async {
    assert(state.name.isNotBlank);

    try {
      emit(state.copyWith(isSubmitting: true));
      await _userRepository.signIn(state.name);
      emit(state.copyWith(isSubmitting: false));
    } on AppFailure catch (failure) {
      _onLoginFailed(failure);
    }
  }

  void _onLoginFailed(AppFailure failure) {
    emit(state.copyWith(loginFailure: failure, isSubmitting: false));
  }

  void onNameChanged(String name) {
    emit(state.copyWith(name: name));
  }

  void resetLoginFailure() {
    emit(state.copyWith(loginFailure: AppFailure.none));
  }
}
