part of 'auth_cubit.dart';

enum AuthStatus {
  unauthenticated,
  authenticated,
}

extension AuthStatusExtensions on AuthStatus {
  bool get isUnauthenticated => this == AuthStatus.unauthenticated;
  bool get isAuthenticated => this == AuthStatus.authenticated;
}

extension AuthStateExtensions on AuthState {
  bool get isUnauthenticated => status.isUnauthenticated;
  bool get isAuthenticated => status.isAuthenticated;
}

class AuthState extends Equatable {
  const AuthState._({
    required this.status,
    this.user = User.none,
  });

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  const AuthState.authenticated(User user)
      : this._(
          status: AuthStatus.authenticated,
          user: user,
        );

  final AuthStatus status;
  final User user;

  @override
  List<Object?> get props => [status, user];
}
