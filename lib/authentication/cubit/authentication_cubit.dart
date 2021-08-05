import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:auth_repository/auth_repository.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({
    required AuthRepository authRepository,
    required Future<void> Function({
      required String name,
      required String authId,
    })
        createUserFunction,
  })  : _authRepository = authRepository,
        _createUserFunction = createUserFunction,
        super(const AuthenticationState.unknown()) {
    _userSubscription = _authRepository.streamAuthUserChanges
        .listen(_authenticationUserChanged);
  }

  final AuthRepository _authRepository;
  final Future<void> Function({required String name, required String authId})
      _createUserFunction;
  StreamSubscription<User?>? _userSubscription;

  User? get user => state.user;

  void _authenticationUserChanged(User? user) => user != null
      ? emit(AuthenticationState.authenticated(user))
      : emit(const AuthenticationState.unauthenticated());

  // todo: differentiate between signIn and register/create account.
  Future<AuthResult> signIn({required String name}) async {
    try {
      final userId = await _authRepository.signIn();

      await _createUserFunction(authId: userId!, name: name);

      return AuthResult.success;
    } catch (error) {
      debugPrint('FAILED TO SIGN IN.');
      debugPrint(error.toString());

      return AuthResult.failure;
    }
  }

  Future<void> signOut() async => await _authRepository.signOut();

  @override
  Future<void> close() {
    _userSubscription?.cancel();

    return super.close();
  }
}
