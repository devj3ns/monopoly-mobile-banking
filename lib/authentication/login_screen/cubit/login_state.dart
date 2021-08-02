part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState({
    this.name = '',
    this.isSubmitting = false,
    this.authResult = AuthResult.none,
  });

  final String name;
  final bool isSubmitting;
  final AuthResult authResult;

  @override
  List<Object> get props => [name, isSubmitting, authResult];

  LoginState copyWith({
    String? name,
    bool? isSubmitting,
    AuthResult? authResult,
  }) {
    return LoginState(
      name: name ?? this.name,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      authResult: authResult ?? this.authResult,
    );
  }
}
