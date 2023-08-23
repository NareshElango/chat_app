//import 'dart:js';

import 'package:flutter/material.dart';

class uihelper {
  static void showloadingdialog(BuildContext context, String title) {
    mainAxisSize:
    MainAxisSize.min;
    AlertDialog loadingdialog = AlertDialog(
      content: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(
              height: 30,
            ),
            Text(title)
          ],
        ),
      ),
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return loadingdialog;
      },
    );
  }

  static void showalertdialog(
      BuildContext context, String title, String content) {
    AlertDialog alertdialog = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Ok"))
      ],
    );

    showDialog(
        context: context,
        builder: (context) {
          return alertdialog;
        });
  }
}
