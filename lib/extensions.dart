import 'package:auth_repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'authentication/cubit/authentication_cubit.dart';

extension ContextExtensions on BuildContext {
  User get user {
    final user = read<AuthenticationCubit>().user;

    assert(user != null);

    return user!;
  }
}
