import 'package:flutter/material.dart';
import '../shared_widgets.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicScaffold(
      appBar: AppBar(
        title: const Text('Monopoly Banking'),
      ),
      child: const Text(
        'Version 0.0.2\n'
        'Monopoly Banking\n\n'
        'Made by Jens Becker\n'
        'jensbecker.dev\n',
        textAlign: TextAlign.center,
      ),
    );
  }
}
