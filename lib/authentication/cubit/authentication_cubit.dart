import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:auth_repository/auth_repository.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthenticationState.unknown()) {
    _userSubscription =
        _authRepository.streamUser.listen(_authenticationUserChanged);
  }

  final AuthRepository _authRepository;
  StreamSubscription<User?>? _userSubscription;

  User? get user => state.user;

  void _authenticationUserChanged(User? user) => user != null
      ? emit(AuthenticationState.authenticated(user))
      : emit(const AuthenticationState.unauthenticated());

  // This logs out the user which triggers the state
  // to change to AuthenticationState.unauthenticated().
  Future<void> logout() async => await _authRepository.signOut();

  @override
  Future<void> close() {
    _userSubscription?.cancel();

    return super.close();
  }
}
