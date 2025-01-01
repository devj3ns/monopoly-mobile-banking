part of 'set_username_cubit.dart';

class SetUsernameState extends Equatable {
  const SetUsernameState({
    this.username = '',
    this.isSubmitting = false,
    this.chooseUsernameResult = SetUsernameResult.none,
  });

  final String username;
  final bool isSubmitting;
  final SetUsernameResult chooseUsernameResult;

  @override
  List<Object> get props => [username, isSubmitting, chooseUsernameResult];

  SetUsernameState copyWith({
    String? username,
    bool? isSubmitting,
    SetUsernameResult? chooseUsernameResult,
  }) {
    return SetUsernameState(
      username: username ?? this.username,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      chooseUsernameResult: chooseUsernameResult ?? this.chooseUsernameResult,
    );
  }
}
