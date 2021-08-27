part of 'app_cubit.dart';

enum AppStatus {
  unauthenticated,
  newlyAuthenticated,
  authenticated,
}

extension AppStatusExtensions on AppStatus {
  bool get isUnauthenticated => this == AppStatus.unauthenticated;
  bool get isNewlyAuthenticated => this == AppStatus.newlyAuthenticated;
  bool get isAuthenticated => this == AppStatus.authenticated;
}

extension AppStateExtensions on AppState {
  bool get isUnauthenticated => status.isUnauthenticated;
  bool get isNewlyAuthenticated => status.isNewlyAuthenticated;
  bool get isAuthenticated => status.isAuthenticated;
}

class AppState extends Equatable {
  const AppState._({
    required this.status,
    this.user = User.none,
  });

  const AppState.unauthenticated() : this._(status: AppStatus.unauthenticated);

  const AppState.newlyAuthenticated(User user)
      : this._(
          status: AppStatus.newlyAuthenticated,
          user: user,
        );

  const AppState.authenticated(User user)
      : this._(
          status: AppStatus.authenticated,
          user: user,
        );

  final AppStatus status;
  final User user;

  @override
  List<Object?> get props => [status, user];
}
