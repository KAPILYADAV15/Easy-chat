import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splashScreen.dart';

// global object for device screen size
late Size screenSize;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // go to full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // also setting the preferred orientation
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    Firebase.initializeApp();

    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
              color: Colors.white,
              centerTitle: true,
              elevation: 2,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.normal,
              ))),
      home: SplashScreen(),
    );
  }
}
