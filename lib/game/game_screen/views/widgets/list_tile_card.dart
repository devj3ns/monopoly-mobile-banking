import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/extensions.dart';
import '../../../../shared/widgets.dart';
import 'animated_balance_text.dart';

class ListTileCard extends StatelessWidget {
  const ListTileCard({
    Key? key,
    required this.icon,
    required this.text,
    this.onTap,
    this.customColor,
    this.moneyBalance,
  }) : super(key: key);

  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final Color? customColor;
  final int? moneyBalance;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        customColor ?? (context.isDarkMode ? Colors.white : Colors.black45);

    final moneyBalanceColor =
        context.isDarkMode ? Colors.white.withOpacity(0.6) : Colors.black54;

    final iconSize = icon.fontPackage == 'font_awesome_flutter' ? 16.0 : 18.0;

    return Card(
      child: ListTile(
        shape: Theme.of(context).cardTheme.shape,
        title: Row(
          children: [
            Expanded(
              child: IconText(
                mainAxisAlignment: MainAxisAlignment.start,
                icon: FaIcon(
                  icon,
                  size: iconSize,
                  color: iconColor,
                ),
                gap: 10,
                text: Text(
                  text,
                  overflow: moneyBalance != null ? TextOverflow.ellipsis : null,
                  style: TextStyle(color: customColor),
                ),
                iconAfterText: false,
              ),
            ),
            if (moneyBalance != null)
              AnimatedMoneyBalanceText(
                moneyBalance: moneyBalance!,
                textStyle: TextStyle(
                  color: moneyBalanceColor,
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
