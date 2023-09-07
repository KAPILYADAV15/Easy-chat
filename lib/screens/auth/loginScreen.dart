// to declare media query global object and use it we need to fist declare it and then we need to initialise it under widgetBuild
// but only inside that widget Build whose parent is materialApp so here we can initialise it inside login screen only

import 'dart:developer';
import 'package:easy_chat/api/apis.dart';
import 'package:easy_chat/utils/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../main.dart';
import '../homeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 500), (() {
      setState(() {
        _isAnimate = true;
      });
    }));
  }

  _handleGoogleButtonClick() {
    Dialogs.showProgressIndicator(context);

    _signInWithGoogle().then((user) async {
      Navigator.pop(context);

      if (user != null) {
        // this is the user which is signed in now
        // log('\nUser: ${user.user}');
        // log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if ((await Apis.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          Apis.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await Apis.auth.signInWithCredential(credential);
    } catch (e) {
      log("\n_signInWithGoogle: $e");
      Dialogs.showSnackbar(
          context,
          "Something went wrong please check your internet connection",
          Colors.red);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to Easy chat"),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              top: screenSize.height * .15,
              width: screenSize.width * .5,
              right:
                  _isAnimate ? screenSize.width * .25 : -screenSize.width * .5,
              duration: Duration(seconds: 1),
              child: Image.asset("assets/icons/launcherIcon.png")),
          Positioned(
            bottom: screenSize.height * .15,
            width: screenSize.width * .9,
            left: screenSize.width * .05,
            height: screenSize.height * .07,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 223, 255, 187),
                  elevation: 1,
                  shape: StadiumBorder(
                      side: BorderSide(color: Colors.grey.shade50)),
                ),
                onPressed: () {
                  _handleGoogleButtonClick();
                },
                icon: Image.asset("assets/icons/google.png"),
                label: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: "Sign in with ",
                        style: TextStyle(fontSize: 18, color: Colors.black)),
                    TextSpan(
                        text: "Google",
                        style: TextStyle(fontSize: 18, color: Colors.black))
                  ]),
                )),
          )
        ],
      ),
    );
  }
}
