import 'package:flutter/material.dart';
import 'package:sonique/utils/colors.dart';
import 'package:sonique/utils/styles.dart';

class WelcomeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool inverted;

  const WelcomeButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.inverted = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: inverted ? AppColors.w_loginBox : Colors.white,
        foregroundColor: inverted ? Colors.white : AppColors.w_text,
        textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
      ),
      child: Text(text),
    );
  }
}
