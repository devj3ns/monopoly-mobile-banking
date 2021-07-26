part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState({
    this.firstName = '',
    this.isSubmitting = false,
    this.authResult = AuthResult.none,
  });

  final String firstName;
  final bool isSubmitting;
  final AuthResult authResult;

  @override
  List<Object> get props => [firstName, isSubmitting, authResult];

  LoginState copyWith({
    String? firstName,
    bool? isSubmitting,
    AuthResult? authResult,
  }) {
    return LoginState(
      firstName: firstName ?? this.firstName,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      authResult: authResult ?? this.authResult,
    );
  }
}
