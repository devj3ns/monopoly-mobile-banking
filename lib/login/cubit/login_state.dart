part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState({
    this.name = '',
    this.isSubmitting = false,
    this.loginFailure = AppFailure.none,
  });

  final String name;
  final bool isSubmitting;
  final AppFailure loginFailure;

  @override
  List<Object> get props => [name, isSubmitting, loginFailure];

  LoginState copyWith({
    String? name,
    bool? isSubmitting,
    AppFailure? loginFailure,
  }) {
    return LoginState(
      name: name ?? this.name,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      loginFailure: loginFailure ?? this.loginFailure,
    );
  }
}
