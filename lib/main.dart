import 'package:flutter/material.dart';
import 'package:sonique/routes/welcome.dart';
import 'package:sonique/routes/login.dart';
import 'package:sonique/routes/signup.dart';
import 'package:sonique/routes/home.dart';
import 'package:sonique/routes/rate.dart';
import 'package:sonique/routes/artist_page.dart';
import 'package:sonique/routes/search.dart';

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
        '/rate': (context) => Rate(),
        '/artist': (context) => ArtistPage(),
        '/search': (context) => Search(),
      },
    ),
  );
}
