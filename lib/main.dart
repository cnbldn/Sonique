import 'package:flutter/material.dart';
import 'package:sonique/navigator.dart';
import 'package:sonique/routes/welcome.dart';
import 'package:sonique/routes/login.dart';
import 'package:sonique/routes/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
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
