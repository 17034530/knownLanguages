// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../DataController.dart';
import '../main.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});
  static String route = 'signup';

  @override
  State<Signup> createState() {
    return _Signup();
  }
}

class _Signup extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  var _gender = UserGender().genderOptions.first;
  final _url = IPSetting().settingUrl();

  void _createProfile() {
    _formKey.currentState!.save();
    String dobSQL = _dob.text.isEmpty
        ? ''
        : FormatDate().formatDateSQL(FormatDate().formatDatePV(_dob.text));
    Map para = {
      'name': _name.text,
      'password': _password.text,
      'email': _email.text,
      'dob': dobSQL,
      'gender': _gender,
    };
    _apiCall('createUser', para, 'POST');
  }

  void _resetField(String message) {
    //to reset field that are TextEditingController
    if (message.contains('Name')) {
      _name.text = '';
    } else if (message.contains('Password')) {
      _password.text = '';
    } else if (message.contains('Email')) {
      _email.text = '';
    } else {
      _name.text = '';
      _password.text = '';
      _email.text = '';
      _dob.text = '';
      _gender = UserGender().genderOptions.first;
    }
  }

  void _login(String title, String message) async {
    Navigator.of(context, rootNavigator: true).pop('OK');
    if (title.contains('Successfully')) {
      Map para = {
        'name': _name.text,
        'password': _password.text,
        'device': await DeviceInfo().getDeviceName(),
      };
      _apiCall('login', para, 'POST');
    }
  }

  void _alertDialog(String title, String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => _login(title, message),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

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
        if (endpoint == 'login') {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('name', _name.text);
          prefs.setString('token', data['token']);
          
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MyApp()));
        } else if (endpoint == 'createUser') {
          _alertDialog('Successfully', data['result']);
        }
      } else {
        if (endpoint == 'createUser') {
          _alertDialog('Error', data['result']);
          _resetField(data['result']);
        }
      }
    } catch (e) {
      _alertDialog('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: const InputDecoration(
                  label: Text('Name:'),
                ),
                controller: _name,
              ),
              TextField(
                decoration: const InputDecoration(
                  label: Text('Password:'),
                ),
                controller: _password,
                obscureText: true,
              ),
              TextField(
                decoration: const InputDecoration(
                  label: Text('Email:'),
                ),
                controller: _email,
              ),
              TextField(
                decoration: const InputDecoration(
                  label: Text('DOB:'),
                ),
                controller: _dob,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _dob.text.isNotEmpty
                        ? FormatDate().formatDatePV(_dob.text)
                        : DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    String formattedDate = FormatDate().formatDate(pickedDate);
                    setState(() {
                      _dob.text = formattedDate;
                    });
                  }
                },
              ),
              const Text(
                'Gender:',
              ),
              DropdownButton<String>(
                value: _gender = UserGender()
                    .genderOptions
                    .elementAt(UserGender().genderOptions.indexOf(_gender)),
                underline: Container(
                  height: 1,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? value) {
                  setState(() {
                    _gender = value!;
                  });
                },
                items: UserGender()
                    .genderOptions
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: _createProfile,
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
