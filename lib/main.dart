import 'package:flutter/material.dart';

import 'home.dart';

void main() => runApp(MonopolyBankingApp());

class MonopolyBankingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monopoly Banking',
      home: HomeScreen(),
    );
  }
}
