import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sonique/navigator.dart';
import 'package:sonique/routes/welcome.dart';
import 'package:sonique/routes/login.dart';
import 'package:sonique/routes/signup.dart';
import 'package:sonique/routes/artist_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(const SoniqueApp());
}

class SoniqueApp extends StatelessWidget {
  const SoniqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Inter',
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(foregroundColor: Colors.white),
        ),
      ),
      title: 'Sonique',
      routes: {
        '/': (context) => Welcome(),
        '/signup': (context) => Signup(),
        '/login': (context) => Login(),
        '/mainNavigator': (context) => MainNavigator(),
      },
      initialRoute: '/',
    );
  }
}
