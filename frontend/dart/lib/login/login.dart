// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:dart/DataController.dart';
import 'package:dart/alert/alert.dart';
import 'package:dart/login/ipsetting.dart';
import 'package:dart/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {
  const Login({super.key});
  static String route = 'login';

  @override
  State<Login> createState() {
    return _Login();
  }
}

class _Login extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  var _name = '';
  var _password = '';

  final _isDebug = kDebugMode;
  final _url = IPSetting().settingUrl();

  void _apiCall(String endpoint, Map para, String method) async {
    try {
      Response response;
      dynamic data;
      if (method == 'POST') {
        response = await post(
          Uri.parse(_url + endpoint),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(para),
        );
        data = jsonDecode(response.body.toString());
      }
      if (data['check']) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('name', _name);
        prefs.setString('token', data['token']);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MyApp()));
      } else {
        showAlertDialog(context, 'Error', data['result']);
      }
    } catch (e) {
      showAlertDialog(context, 'Error', e.toString());
    }
  }

  void _saveItem() async {
    _formKey.currentState!.save();
    // print(await getDeviceName());

    Map para = {
      'name': _name,
      'password': _password,
      'device': await DeviceInfo().getDeviceName(),
    };
    _apiCall('login', para, 'POST');
  }

  void _signupPage() {
    Navigator.of(context).pushNamed('signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: !_isDebug
            ? []
            : <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(IpSetting.route),
                    child: const Icon(
                      Icons.settings,
                      size: 26.0,
                    ),
                  ),
                ),
              ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 10, 10),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text('Name'),
                  ),
                  onSaved: (value) {
                    _name = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text('Password'),
                  ),
                  onSaved: (value) {
                    _password = value!;
                  },
                  obscureText: true,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveItem,
                        child: const Text('Login'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _signupPage,
                        child: const Text('Sign up'),
                      ),
                    ),
                  ],
                )
              ],
            )),
      ),
    );
  }
}
