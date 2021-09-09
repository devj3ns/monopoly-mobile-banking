import 'package:banking_repository/banking_repository.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

extension ContextExtensions on BuildContext {
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

  /// Whether the overall theme brightness is dark.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Whether the overall theme brightness is light.
  bool get isLightMode => Theme.of(this).brightness == Brightness.light;
}

extension StringExtensions on String {
  /// Capitalizes the first letter of the string.
  String capitalize() {
    return isBlank ? this : this[0].toUpperCase() + substring(1);
  }
}
