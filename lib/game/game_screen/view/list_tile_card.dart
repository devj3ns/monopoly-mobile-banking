import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../extensions.dart';
import '../../../shared_widgets.dart';
import 'animated_balance_text.dart';

class ListTileCard extends StatelessWidget {
  const ListTileCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.generateUniqueColorKey,
    this.moneyBalance,
  }) : super(key: key);

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final String? generateUniqueColorKey;
  final int? moneyBalance;

  @override
  Widget build(BuildContext context) {
    Color _generateUniqueColor() {
      assert(generateUniqueColorKey != null);

      final chars = generateUniqueColorKey!;

      var hash = 0;
      for (var i = 0; i < chars.length; i++) {
        hash = chars.codeUnitAt(i) + ((hash << 5) - hash);
      }
      final finalHash = hash.abs() % (256 * 256 * 256);

      final red = ((finalHash & 0xFF0000) >> 16);
      final blue = ((finalHash & 0xFF00) >> 8);
      final green = ((finalHash & 0xFF));
      final color = Color.fromRGBO(red, green, blue, 1);

      return color;
    }

    final iconColor = generateUniqueColorKey != null
        ? _generateUniqueColor()
        : context.isDarkMode
            ? Colors.white
            : Colors.black45;

    final textColor = generateUniqueColorKey != null
        ? _generateUniqueColor()
        : context.isDarkMode
            ? Colors.white
            : Theme.of(context).textTheme.bodyText2!.color!;

    final moneyBalanceColor = context.isDarkMode ? Colors.grey : Colors.black54;

    final showMoneyBalanceText = moneyBalance != null;

    final iconSize = icon.fontPackage == 'font_awesome_flutter' ? 16.0 : 18.0;

    return Card(
      child: ListTile(
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
                  overflow: showMoneyBalanceText ? TextOverflow.ellipsis : null,
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
                iconAfterText: false,
              ),
            ),
            if (showMoneyBalanceText)
              AnimatedBalanceText(
                balance: moneyBalance!,
                textStyle: TextStyle(
                  fontSize: 17,
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
