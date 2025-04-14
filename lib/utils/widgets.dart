import 'package:flutter/material.dart';
import 'package:sonique/utils/styles.dart';

class WelcomeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;

  const WelcomeButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color =
        Colors
            .white, // maybe change this to a bool accent, where 1: accent color, 0: default color.
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(text));
  }
}
