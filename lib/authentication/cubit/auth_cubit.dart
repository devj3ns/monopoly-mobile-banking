import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:user_repository/user_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.userRepository,
  }) : super(userRepository.user.isNone
            ? const AuthState.unauthenticated()
            : AuthState.authenticated(userRepository.user)) {
    _watchUser();
  }

  final UserRepository userRepository;

  @override
  Future<void> close() async {
    await _unwatchUser();

    return super.close();
  }

  Future<void> signOut() async {
    await userRepository.signOut();
  }

  void _onUserChanged(User user) {
    if (user.isNone) {
      emit(const AuthState.unauthenticated());
    } else {
      emit(AuthState.authenticated(user));
    }
  }

  late final StreamSubscription _userSubscription;
  void _watchUser() {
    _userSubscription = userRepository.watchUser.listen(_onUserChanged);
  }

  Future<void> _unwatchUser() {
    return _userSubscription.cancel();
  }
}
