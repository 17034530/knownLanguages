import 'package:dart/main.dart';
import 'package:flutter/material.dart';

showAlertDialog(BuildContext context, String title, String message) {
  void onPress() {
    Navigator.of(context, rootNavigator: true).pop('OK');
    if (context.toString().contains('IpSetting')) {
      if (message.contains('Your new IP address')) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MyApp()));
      }
    }
  }

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: onPress,
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
