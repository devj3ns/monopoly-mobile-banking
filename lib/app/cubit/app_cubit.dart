import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(userRepository.user.isNone
            ? const AppState.unauthenticated()
            : AppState.newlyAuthenticated(userRepository.user)) {
    _watchUser();
  }

  final UserRepository _userRepository;

  @override
  Future<void> close() async {
    await _unwatchUser();

    return super.close();
  }

  Future<void> signOut() async {
    await _userRepository.signOut();
  }

  void _onUserChanged(User user) {
    if (user.isNone) {
      emit(const AppState.unauthenticated());
    } else if (state.isUnauthenticated) {
      emit(AppState.newlyAuthenticated(user));
    } else {
      emit(AppState.authenticated(user));
    }
  }

  late final StreamSubscription _userSubscription;
  void _watchUser() {
    _userSubscription = _userRepository.watchUser.listen(_onUserChanged);
  }

  Future<void> _unwatchUser() {
    return _userSubscription.cancel();
  }
}
