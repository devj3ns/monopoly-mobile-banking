import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A Scaffold with a pre-defined layout.
class BasicScaffold extends StatelessWidget {
  const BasicScaffold({
    Key? key,
    required this.child,
    required this.appBar,
  }) : super(key: key);

  final AppBar appBar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A Scaffold with a pre-defined layout.
class BasicListViewScaffold extends StatelessWidget {
  const BasicListViewScaffold({
    Key? key,
    required this.children,
    required this.appBar,
  }) : super(key: key);

  final AppBar appBar;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: children,
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
    this.iconSize,
    this.fontSize,
    this.color,
    this.iconAfterText = true,
  }) : super(key: key);

  final IconData icon;
  final String text;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;
  final double gap;
  final double? iconSize;
  final double? fontSize;
  final Color? color;
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
            FaIcon(
              icon,
              size: iconSize,
              color: color,
            ),
            SizedBox(width: gap),
          ],
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: fontSize, color: color),
            ),
          ),
          if (iconAfterText) ...[
            SizedBox(width: gap),
            FaIcon(
              icon,
              size: iconSize,
              color: color,
            ),
          ]
        ],
      ),
    );
  }
}
