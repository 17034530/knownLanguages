import 'package:flutter/material.dart';
import '../DataController.dart';
import '../alert/alert.dart';

class IpSetting extends StatefulWidget {
  const IpSetting({super.key});
  static String route = 'ipsetting';

  @override
  State<IpSetting> createState() {
    return _IpSetting();
  }
}

class _IpSetting extends State<IpSetting> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ipAddress = TextEditingController();
  final TextEditingController _port = TextEditingController();
  final _ipSetting = IPSetting();

  void _addIpBtn() {
    if (_ipAddress.text.isEmpty || _port.text.isEmpty) {
      showAlertDialog(context, 'Error', 'Ip address or Port cannot be empty');
    } else {
      _ipSetting.setIPAddress(_ipAddress.text);
      _ipSetting.setPort(_port.text);
      var ipaddressAlert = _ipSetting.getIPAddress();
      var portAlert = _ipSetting.getPort();
      showAlertDialog(context, 'Updated',
          'Your new IP address is $ipaddressAlert and port is $portAlert');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ip Setting'),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('IP address:'),
                  Flexible(
                    child: TextField(
                      controller: _ipAddress,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Port:'),
                  const SizedBox(width: 43),
                  Flexible(
                    child: TextField(
                      controller: _port,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _addIpBtn,
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
