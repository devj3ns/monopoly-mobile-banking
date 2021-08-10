import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:auth_repository/auth_repository.dart';
import 'package:banking_repository/banking_repository.dart';

extension ContextExtensions on BuildContext {
  /// Reads the AuthRepository.
  ///
  /// NOTE: Only call this when there is an ancestor provider of type AuthRepository!
  AuthRepository authRepository() => read<AuthRepository>();

  /// Reads the BankingRepository.
  ///
  /// NOTE: Only call this when there is an ancestor provider of type BankingRepository!
  BankingRepository bankingRepository() => read<BankingRepository>();

  /// Returns the correctly formatted balance based on the current locale.
  String formatBalance(int balance) {
    final locale = Localizations.localeOf(this);
    final numberFormat = NumberFormat.currency(
      locale: locale.toLanguageTag(),
      symbol: '\$',
      decimalDigits: 0,
    );

    return numberFormat.format(balance);
  }
}
