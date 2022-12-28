import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

import 'bootstrap.dart';
import 'firebase_options_staging.dart';

void main() async {
  Routemaster.setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  bootstrap();
}
