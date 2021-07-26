import 'package:flutter/material.dart';

import 'home.dart';

void main() => runApp(const MonopolyBankingApp());

class MonopolyBankingApp extends StatelessWidget {
  const MonopolyBankingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Monopoly Banking',
      home: HomeScreen(),
    );
  }
}
