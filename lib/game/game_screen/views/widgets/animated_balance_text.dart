import 'package:flutter/material.dart';

import '../../../../extensions.dart';

class AnimatedBalanceText extends StatelessWidget {
  const AnimatedBalanceText({
    Key? key,
    required this.balance,
    this.textStyle,
  }) : super(key: key);

  final int balance;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          child: child,
          scale: CurveTween(curve: Curves.easeInOut).animate(animation),
        );
      },
      child: Text(
        context.formatBalance(balance),
        key: ValueKey(context.formatBalance(balance)),
        style: textStyle,
      ),
    );
  }
}
