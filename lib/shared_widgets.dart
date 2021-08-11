import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';

/// A Scaffold with a pre-defined max width and padding.
class BasicScaffold extends StatelessWidget {
  const BasicScaffold({
    Key? key,
    required this.child,
    required this.appBar,
    this.applyPadding = true,
  }) : super(key: key);

  final AppBar appBar;
  final Widget child;
  final bool applyPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: EdgeInsets.all(applyPadding ? 8.0 : 0.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A Widget which makes it easy to display an icon next to a text.
class IconText extends StatelessWidget {
  const IconText({
    Key? key,
    required this.icon,
    required this.text,
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.gap = 5,
    this.iconAfterText = true,
  }) : super(key: key);

  final Widget icon;
  final Widget text;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;
  final double gap;
  final bool iconAfterText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.xxs),
      child: Row(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: mainAxisAlignment,
        children: [
          if (!iconAfterText) ...[
            icon,
            SizedBox(width: gap),
          ],
          Flexible(
            child: text,
          ),
          if (iconAfterText) ...[
            SizedBox(width: gap),
            icon,
          ]
        ],
      ),
    );
  }
}