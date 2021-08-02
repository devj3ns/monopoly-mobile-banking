import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:auth_repository/auth_repository.dart';
import 'package:user_repository/user_repository.dart' hide User;

extension ContextExtensions on BuildContext {
  AuthRepository authRepository() => read<AuthRepository>();

  UserRepository userRepository() => read<UserRepository>();
}
