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

/// Colored genre cards in the search section.
Widget genreTile(String asset, String label, double w, double h) {
  return GestureDetector(
    onTap: () => debugPrint('Tapped $label'),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Image.asset(asset, width: w, height: h, fit: BoxFit.cover),
          Container(color: const Color(0x55000000)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(label, style: AppTextStyles.sectionHeader),
            ),
          ),
        ],
      ),
    ),
  );
}
