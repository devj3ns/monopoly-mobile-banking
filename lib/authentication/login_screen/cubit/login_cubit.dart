import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:auth_repository/auth_repository.dart';
import 'package:monopoly_banking/authentication/cubit/authentication_cubit.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this.authenticationCubit) : super(const LoginState());

  final AuthenticationCubit authenticationCubit;

  void nameChanged(String name) {
    emit(state.copyWith(name: name));
  }

  void resetAuthResult() {
    emit(state.copyWith(authResult: AuthResult.none));
  }

  Future<void> onFormSubmitted() async {
    emit(state.copyWith(isSubmitting: true));

    final authResult =
        await authenticationCubit.signIn(name: state.name);

    emit(state.copyWith(isSubmitting: false, authResult: authResult));
  }
}
