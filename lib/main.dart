import 'package:flutter/material.dart';
import 'package:sonique/navigator.dart';
import 'package:sonique/routes/welcome.dart';
import 'package:sonique/routes/login.dart';
import 'package:sonique/routes/signup.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(fontFamily: 'Inter'),
      title: 'Sonique',
      routes: {
        '/': (context) => Welcome(),
        '/signup': (context) => Signup(),
        '/login': (context) => Login(),
        '/mainNavigator': (context) => MainNavigator(),
      },
      initialRoute: '/',
    ),
  );
}
