// to declare media query global object and use it we need to fist declare it and then we need to initialise it under widgetBuild
// but only inside that widget Build whose parent is materialApp so here we can initialise it inside login screen only

import 'package:easy_chat/api/apis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import 'auth/loginScreen.dart';
import 'homeScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 2), (() {

      // exiting the full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      // to change the status bar colour
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(systemNavigationBarColor: Colors.white, statusBarColor: Colors.white ));
        // SystemUiOverlayStyle(statusBarColor: Colors.transparent));

      if(Apis.auth.currentUser != null){
        // Navigate to Home Screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
      else{
        // Navigate to Login Screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }


    }));
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: screenSize.height * .15,
              width: screenSize.width * .5,
              right: screenSize.width * .25,
              child: Image.asset("assets/icons/launcherIcon.png", fit: BoxFit.fitHeight,),),
          Positioned(
            bottom: screenSize.height * .20,
            width: screenSize.width,
            child: Text(
              "MADE BY KAPIL YADAV 😎 ",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                fontWeight: FontWeight.w700
              ),
            ),
          )
        ],
      ),
    );
  }
}
