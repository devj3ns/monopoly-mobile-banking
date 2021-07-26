import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:auth_repository/auth_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this.authRepository) : super(const LoginState());

  final AuthRepository authRepository;

  void firstNameChanged(String firstName) {
    emit(state.copyWith(firstName: firstName));
  }

  void resetAuthResult() {
    emit(state.copyWith(authResult: AuthResult.none));
  }

  Future<void> onFormSubmitted() async {
    emit(state.copyWith(isSubmitting: true));

    final authResult = await authRepository.signIn(
      firstName: state.firstName,
    );

    if (authResult == AuthResult.success) {
      // Don't set isSubmitting to false because of the time
      // the auth_repository needs to get the user data from the database
      emit(state.copyWith(authResult: authResult));
    } else {
      emit(state.copyWith(isSubmitting: false, authResult: authResult));
    }
  }
}
