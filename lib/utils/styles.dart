import 'package:flutter/material.dart';
import 'package:sonique/utils/colors.dart';

class AppTextStyles {
  // welcome, login, signup

  /// text on login button
  static const welcomeButton = TextStyle();

  /// text inside textboxes
  static const welcomeSmall = TextStyle(
    color: AppColors.text,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.16,
  );

  /// big bold text up top
  static const welcomeTitle = TextStyle(
    color: Colors.white,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.16,
  );

  //home
}

class AppBorders {
  static const formBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide.none,
  );

  static const focusedFormBorder = OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.sonique_purple, width: 2),
  );
}
