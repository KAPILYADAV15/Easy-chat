import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String msg, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
    ));
  }
  static void showProgressIndicator(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => Center(child: CircularProgressIndicator())
    );
  }

}

