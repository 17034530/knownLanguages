import 'dart:io';

import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  // static String route = 'home';

  @override
  Widget build(BuildContext context) {
    return WillPopScope( //to prevent an issus after login when user click on back button
      onWillPop: () async {
        if (Navigator.canPop(context)) {
          return true;
        } else {
          if(Platform.isAndroid){
            return true; 
          }
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
      ),
    );
  }
}
