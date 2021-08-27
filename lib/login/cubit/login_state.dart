part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState({
    this.username = '',
    this.isSubmitting = false,
    this.signInResult = SignInResult.none,
  });

  final String username;
  final bool isSubmitting;
  final SignInResult signInResult;

  @override
  List<Object> get props => [username, isSubmitting, signInResult];

  LoginState copyWith({
    String? username,
    bool? isSubmitting,
    SignInResult? signInResult,
  }) {
    return LoginState(
      username: username ?? this.username,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      signInResult: signInResult ?? this.signInResult,
    );
  }
}
