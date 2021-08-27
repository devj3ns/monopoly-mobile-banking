part of 'choose_username_cubit.dart';

class ChooseUsernameState extends Equatable {
  const ChooseUsernameState({
    this.username = '',
    this.isSubmitting = false,
    this.chooseUsernameResult = ChooseUsernameResult.none,
  });

  final String username;
  final bool isSubmitting;
  final ChooseUsernameResult chooseUsernameResult;

  @override
  List<Object> get props => [username, isSubmitting, chooseUsernameResult];

  ChooseUsernameState copyWith({
    String? username,
    bool? isSubmitting,
    ChooseUsernameResult? chooseUsernameResult,
  }) {
    return ChooseUsernameState(
      username: username ?? this.username,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      chooseUsernameResult: chooseUsernameResult ?? this.chooseUsernameResult,
    );
  }
}
