import 'package:flutter/material.dart';
import 'package:sonique/utils/colors.dart';
import 'package:sonique/routes/welcome.dart';
import 'package:sonique/routes/login.dart';
import 'package:sonique/routes/signup.dart';
import 'package:sonique/routes/home.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Sonique',
      initialRoute: '/login',
      routes: {
        '/': (context) => Welcome(),
        '/signup': (context) => Signup(),
        '/login': (context) => Login(),
        '/home': (context) => Home(),
      },
    ),
  );
}
