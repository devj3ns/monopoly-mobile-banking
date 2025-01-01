import 'package:cached_network_image/cached_network_image.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:fleasy/fleasy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'theme.dart';

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

/// Use context.showModalBottomSheet to show it.
class MyModalBottomSheet extends StatelessWidget {
  const MyModalBottomSheet({
    Key? key,
    this.showHandle = true,
    required this.child,
  }) : super(key: key);

  final bool showHandle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).dialogBackgroundColor,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 0),
        padding: EdgeInsets.only(
          left: 8,
          right: 8,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showHandle)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.7),
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                    ),
                    width: 45,
                    height: 4,
                  ),
                ),
              ),
            child,
          ],
        ),
      ),
    );
  }
}

class ExpansionCard extends HookWidget {
  const ExpansionCard({
    Key? key,
    required this.header,
    this.headerPadding = const EdgeInsets.all(8),
    required this.body,
    this.bodyPadding = const EdgeInsets.all(8),
  }) : super(key: key);

  final Widget header;
  final EdgeInsets headerPadding;
  final Widget body;
  final EdgeInsets bodyPadding;

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);

    return Card(
      child: Column(
        children: [
          InkWell(
            borderRadius: borderRadius,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: headerPadding,
                    child: header,
                  ),
                ),
                ExpandIcon(
                  isExpanded: isExpanded.value,
                  onPressed: (_) => isExpanded.value = !isExpanded.value,
                ),
              ],
            ),
            onTap: () => isExpanded.value = !isExpanded.value,
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0.0),
            secondChild: Padding(
              padding: bodyPadding,
              child: body,
            ),
            firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
            secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
            sizeCurve: Curves.fastOutSlowIn,
            crossFadeState: isExpanded.value
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class BigGradientButton extends StatelessWidget {
  const BigGradientButton({
    Key? key,
    required this.gradientColors,
    required this.label,
    required this.onTap,
    required this.icon,
  }) : super(key: key);

  final List<Color> gradientColors;
  final String label;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(9)),
        gradient: LinearGradient(
          colors: gradientColors,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(Radius.circular(9)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.3),
                    borderRadius: const BorderRadius.all(Radius.circular(9)),
                  ),
                  child: Icon(icon),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
