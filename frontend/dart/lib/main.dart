import 'package:dart/MTB/maintabbar.dart';
import 'package:dart/login/ipsetting.dart';
import 'package:dart/login/login.dart';
import 'package:dart/login/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  await dotenv.load(fileName: "lib/config/config.env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static String route = '';

  @override
  State<MyApp> createState() {
    return _MyApp();
  }
}

class _MyApp extends State<MyApp> {
  bool _isLogin = false;
  Map<String, WidgetBuilder> _activeRoutes = {
    Login.route: (context) => const Login(),
    IpSetting.route: (context) => const IpSetting(),
    Signup.route: (context) => const Signup(),
    MainTabBar.route: (context) => const MyApp(),
  };
  var _initialRoute = '';

  @override
  void initState() {
    super.initState();
    _loadIsLogin();
  }

  void _loadIsLogin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLogin = prefs.getString('token') != null;
      if (prefs.getString('token') != null) {
        _activeRoutes = {
          MainTabBar.route: (context) => const MainTabBar(),
          Login.route: (context) => const MyApp(),
        };
        _initialRoute = MainTabBar.route;
      } else {
        _initialRoute = Login.route;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        initialRoute: _initialRoute,
        routes: _activeRoutes,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: _isLogin ? const MainTabBar() : const Login());
  }
}
