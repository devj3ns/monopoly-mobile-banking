import 'package:cached_network_image/cached_network_image.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A Scaffold with a pre-defined max width and padding.
class BasicScaffold extends StatelessWidget {
  const BasicScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.applyPadding = true,
  }) : super(key: key);

  final Widget body;
  final AppBar? appBar;
  final bool applyPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SafeArea(
            child: applyPadding
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: body,
                  )
                : body,
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

/// A money balance form field.
class MoneyBalanceFormField extends StatelessWidget {
  const MoneyBalanceFormField({
    Key? key,
    required this.onChanged,
    this.controller,
    this.onEditingComplete,
    this.validator,
    this.textInputAction,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.autofocus = false,
  }) : super(key: key);

  final Function(int) onChanged;
  final TextEditingController? controller;
  final VoidCallback? onEditingComplete;
  final String? Function(int)? validator;
  final TextInputAction? textInputAction;
  final String? labelText;
  final String? hintText;
  final int? initialValue;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final inputFormatter = CurrencyTextInputFormatter(
      locale: Localizations.localeOf(context).toLanguageTag(),
      symbol: '\$',
      decimalDigits: 0,
    );

    return TextFormField(
      initialValue: initialValue != null
          ? inputFormatter.format(initialValue.toString()).toString()
          : null,
      autovalidateMode: controller == null
          ? null
          : controller!.text.isEmpty
              ? AutovalidateMode.disabled
              : AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hintText,
        label: labelText != null ? Text(labelText!) : null,
      ),
      keyboardType: TextInputType.number,
      controller: controller,
      inputFormatters: [inputFormatter],
      validator: (value) => validator?.call(
        value.toString().isBlank
            ? 0
            : int.parse(value!.replaceAll(RegExp(r'[^0-9]+'), '')),
      ),
      onChanged: (value) => onChanged(
        value.toString().isBlank
            ? 0
            : int.parse(value.replaceAll(RegExp(r'[^0-9]+'), '')),
      ),
      onEditingComplete: onEditingComplete,
      textInputAction: TextInputAction.done,
      autofocus: autofocus,
    );
  }
}

/// A cached profile picture widget which also works on the web.
class ProfilePicture extends StatelessWidget {
  const ProfilePicture({
    Key? key,
    required this.photoURL,
    required this.radius,
  }) : super(key: key);

  final String photoURL;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image.network(
              photoURL,
              width: radius * 2,
              height: radius * 2,
              filterQuality: FilterQuality.medium,
              fit: BoxFit.cover,
            ),
          )
        : CircleAvatar(
            radius: radius,
            backgroundImage: CachedNetworkImageProvider(photoURL),
            backgroundColor: Colors.transparent,
          );
  }
}
