// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:dart/DataController.dart';
import 'package:dart/MTB/maintabbar.dart';
import 'package:dart/main.dart';
import 'package:dart/ui/labelvalue.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../alert/alert.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  static String route = 'profile';

  @override
  State<Profile> createState() {
    return _Profile();
  }
}

class _Profile extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  var _name = '';
  var _token = '';
  var _currentPassword = '';
  var _newPassword = '';
  final TextEditingController _email = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  var _gender = UserGender().genderOptions.first;
  final _url = IPSetting().settingUrl();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token')!;
      _name = prefs.getString('name')!;
    });
    Map para = {
      'name': prefs.getString('name')!,
      'token': prefs.getString('token')!,
    };
    _apiCall('profile', para, "POST");
  }

  void _updateProfile() {
    _formKey.currentState!.save();
    String dobSQL = _dob.text.isEmpty
        ? ''
        : FormatDate().formatDateSQL(FormatDate().formatDatePV(_dob.text));

    Map para = {
      'name': _name,
      'password': _currentPassword,
      'newPassword': _newPassword,
      'email': _email.text,
      'dob': dobSQL,
      'gender': _gender,
      'token': _token,
    };
    _apiCall('updateProfile', para, 'PATCH');
    _formKey.currentState!
        .reset(); //reset field that are not TextEditingController
  }

  void _logout() async {
    Map para = {
      'name': _name,
      'token': _token,
    };
    _apiCall('logout', para, 'DELETE');
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
      } else if (method == 'PATCH') {
        response = await patch(
          Uri.parse(_url + endpoint),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(para),
        );
        data = jsonDecode(response.body.toString());
      } else if (method == 'DELETE') {
        response = await delete(
          Uri.parse(_url + endpoint),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(para),
        );
        data = jsonDecode(response.body.toString());
      }

      if (data['check']) {
        if (endpoint == 'profile') {
          var resultData = data['result'][0];
          setState(() {
            _email.text = resultData['email'];
            _dob.text = resultData['DOB'] != null
                ? FormatDate().formatDate(
                    FormatDate().formatDateFromSQL(resultData['DOB']))
                : '';
            _gender = resultData['gender'] == null
                ? UserGender().genderOptions.first
                : UserGender().genderOptions.elementAt(
                    UserGender().genderOptions.indexOf(resultData['gender']));
          });
        } else if (endpoint == 'updateProfile') {
          showAlertDialog(context, 'Successfully', data['result']);
        } else if (endpoint == 'logout') {
          final prefs = await SharedPreferences.getInstance();
          prefs.clear();
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MyApp()));
        }
      } else {
        showAlertDialog(context, 'Error', data['result']);
      }
    } catch (e) {
      showAlertDialog(context, 'Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.canPop(context)) {
          return true;
        } else {
          if (Platform.isAndroid) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainTabBar()));
            return true;
          }
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LabelValueRow(label: 'Name:', value: _name),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text('Current Password:'),
                  ),
                  onSaved: (value) {
                    _currentPassword = value!;
                  },
                  obscureText: true,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text('New Password:'),
                  ),
                  onSaved: (value) {
                    _newPassword = value!;
                  },
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
                        lastDate: DateTime.now());
                    if (pickedDate != null) {
                      String formattedDate =
                          FormatDate().formatDate(pickedDate);
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
                  onPressed: _updateProfile,
                  child: const Text('Update'),
                ),
                ElevatedButton(
                  onPressed: _logout,
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
