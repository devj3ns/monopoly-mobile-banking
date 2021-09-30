import 'package:fleasy/fleasy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:routemaster/routemaster.dart';

class JoinGameForm extends HookWidget {
  const JoinGameForm({Key? key}) : super(key: key);

  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final gameId = useState('');

    void submitForm() {
      if (_formKey.currentState!.validate()) {
        Navigator.of(context).pop();
        Routemaster.of(context).replace('/game/${gameId.value}');
      }
    }

    return Form(
      key: _formKey,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Game ID',
                prefix: Text('#'),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              onChanged: (id) => gameId.value = id,
              onEditingComplete: submitForm,
              textInputAction: TextInputAction.go,
              validator: (v) => v.isBlank
                  ? 'Please enter a game ID.'
                  : v!.length < 4
                      ? 'The game ID must be 4 characters long.'
                      : null,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]+')),
                LengthLimitingTextInputFormatter(4),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.login_rounded),
            onPressed: submitForm,
          ),
        ],
      ),
    );
  }
}
