import 'package:flutter/material.dart';
import 'package:sonique/utils/colors.dart';
import 'package:sonique/routes/welcome.dart';
import 'package:sonique/routes/login.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Sonique',
      initialRoute: '/login',
      routes: {
        '/': (context) => Welcome(),
        //'/signup': (context) => SignUp(),
        '/login': (context) => Login(),
      },
    ),
  );
}
