import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    void onTap() {
      Navigator.of(context).pop();
      onPressed();
    }

    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
