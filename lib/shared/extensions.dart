import 'package:banking_repository/banking_repository.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'widgets.dart';

extension ContextExtensions on BuildContext {
  /// Reads the BankingRepository.
  ///
  /// NOTE: Only call this when there is an ancestor provider of type BankingRepository!
  BankingRepository bankingRepository() => read<BankingRepository>();

  /// Returns the correctly formatted money balance based on the current locale.
  String formatMoneyBalance(int moneyBalance) {
    final locale = Localizations.localeOf(this);
    final numberFormat = NumberFormat.currency(
      locale: locale.toLanguageTag(),
      symbol: '\$',
      decimalDigits: 0,
    );

    return numberFormat.format(moneyBalance);
  }

  /// Whether the overall theme brightness is dark.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Whether the overall theme brightness is light.
  bool get isLightMode => Theme.of(this).brightness == Brightness.light;

  /// Shows a modal bottom sheet.
  Future<void> showModalBottomSheet({
    required Widget child,
    bool showHandle = true,
  }) {
    return showCupertinoModalBottomSheet<Widget>(
      context: this,
      builder: (context) => MyModalBottomSheet(
        showHandle: showHandle,
        child: child,
      ),
    );
  }
}

extension StringExtensions on String {
  /// Capitalizes the first letter of the string.
  String capitalize() {
    return isBlank ? this : this[0].toUpperCase() + substring(1);
  }
}

extension DurationExtensions on Duration {
  /// Formats a duration, e.g.: 10s, 31min, 2h, 3:10h
  String format() {
    if (inSeconds < 60) {
      return '${inSeconds}s';
    } else if (inMinutes < 60) {
      return '${inMinutes}min';
    } else {
      return inMinutes % 60 == 0
          ? '${inHours}h'
          : '$inHours:${(inMinutes % 60).toString().padLeft(2, '0')}h';
    }
  }
}

extension DateTimeExtensions on DateTime {
  /// Example outputs with time: Today 9:00, Yesterday 17:00 or 18.02.21 10:00
  /// Example outputs without time: Today, Yesterday or 18.02.21
  String formatTimestamp({bool withTime = true}) {
    final date = isToday
        ? 'Today'
        : isYesterday
            ? 'Yesterday'
            : format('dd.MM.yy');

    if (withTime) {
      final time = format('HH:mm');

      return '$date, $time';
    } else {
      return date;
    }
  }
}
