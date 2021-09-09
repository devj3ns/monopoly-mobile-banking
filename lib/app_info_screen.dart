import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'shared_widgets.dart';

class AppInfoScreen extends HookWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appVersion = useFuture(PackageInfo.fromPlatform()).data?.version;

    return BasicScaffold(
      appBar: AppBar(
        title: const Text('About the app'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 25),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyText2,
              children: [
                const TextSpan(
                  text: 'Monopoly Banking\n',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                TextSpan(
                  text: 'Version $appVersion\n\n'
                      'Made by Jens Becker\n',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                TextSpan(
                  text: 'jensbecker.dev',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => launch('https://jensbecker.dev'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'This app replaces the play money of every Monopoly board game. '
            'Every player can see his money balance on his phone and make transactions from and to players or the bank through the app easily.'
            '\n\n'
            'How to use this app:\n'
            ' 1. All players have to install the app on their phone.\n'
            ' 2. One player creates a new game/lobby.\n'
            ' 3. All players connect to this game/lobby.\n'
            ' 4. Now all transactions can be done via the app, e.g. sending a player money or getting money from the bank.\n'
            ' 5. Have fun :)\n'
            '\n\n'
            'NOTE: This project is still in early stages. If you have ideas, find bugs or have suggestions use the buttons below:',
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const IconText(
                  text: Text('Get help'),
                  gap: 7,
                  icon: FaIcon(
                    FontAwesomeIcons.questionCircle,
                    size: 17,
                  ),
                ),
                onPressed: () => launch(
                    'mailto:info@jensbecker.dev?subject=[Help] Monopoly Banking App'),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                child: const IconText(
                  text: Text('Submit feedback'),
                  gap: 10,
                  icon: FaIcon(
                    FontAwesomeIcons.comments,
                    size: 17,
                  ),
                ),
                onPressed: () => launch(
                    'mailto:info@jensbecker.dev?subject=[Feedback] Monopoly Banking App'),
              ),
            ],
          ),
          const Expanded(child: SizedBox()),
          TextButton(
            child: const Text('Licences'),
            onPressed: () => showLicensePage(
              context: context,
              applicationVersion: 'Version $appVersion',
              applicationLegalese: 'Made by Jens Becker',
            ),
          )
        ],
      ),
    );
  }
}
