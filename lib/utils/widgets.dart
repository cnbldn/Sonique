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
        backgroundColor: inverted ? AppColors.sonique_purple : Colors.white,
        foregroundColor: inverted ? Colors.white : AppColors.text,
        textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text),
    );
  }
}

class myAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: SizedBox(
        height: 25,
        child: Image.asset('assets/logo.png', fit: BoxFit.contain),
      ),
      backgroundColor: AppColors.w_background,
      centerTitle: true,
    );
  }
}
