part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState({
    this.isSubmitting = false,
    this.signInResult = SignInResult.none,
  });

  final bool isSubmitting;
  final SignInResult signInResult;

  @override
  List<Object> get props => [isSubmitting, signInResult];

  LoginState copyWith({
    bool? isSubmitting,
    SignInResult? signInResult,
  }) {
    return LoginState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      signInResult: signInResult ?? this.signInResult,
    );
  }
}
