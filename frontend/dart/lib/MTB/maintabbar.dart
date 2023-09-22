import 'dart:io';

import 'package:dart/MTB/home.dart';
import 'package:dart/MTB/profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MainTabBar extends StatelessWidget {
  const MainTabBar({super.key});
  static String route = 'home';

  @override
  Widget build(BuildContext context) {
    TabBar tabBar() {
      return const TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: <Widget>[
          Tab(
            icon: Icon(Icons.home),
          ),
          Tab(
            icon: Icon(Icons.person),
          ),
        ],
      );
    }

    TabBarView tabBarView() {
      return const TabBarView(
        children: <Widget>[
          Tab(
            child: Home(),
          ),
          Tab(
            child: Profile(),
          ),
        ],
      );
    }

    return DefaultTabController(
      length: 2,
      child: kIsWeb
          ? Scaffold(
              appBar: AppBar(title: tabBar()),
              body: tabBarView(),
            )
          : Scaffold(
              bottomNavigationBar: Container(
                padding: Platform.isAndroid ? const EdgeInsets.fromLTRB(0, 0, 0, 5) : const EdgeInsets.fromLTRB(0, 0, 0, 50),
                child: tabBar(),
              ),
              body: tabBarView()),
    );
  }
}
