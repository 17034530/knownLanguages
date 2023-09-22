// ignore_for_file: file_names
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_info_plus/device_info_plus.dart';


class IPSetting {
  String _ipaddress = '';
  String _port = '';

  IPSetting._internal();

  static final IPSetting _singleton = IPSetting._internal();

  factory IPSetting() {
    return _singleton;
  }

  String getIPAddress() {
    return _ipaddress;
  }

  String getPort() {
    return _port;
  }

  void setIPAddress(String ipaddress) {
    _ipaddress = ipaddress;
  }

  void setPort(String port) {
    _port = port;
  }

  String setUrl() {
    if (_ipaddress.isEmpty && _port.isEmpty) {
      _ipaddress = '192.168.1.68';
      _port = '3000';
    }
    return 'http://$_ipaddress:$_port/';
  }

  String settingUrl() {
    if (_ipaddress.isEmpty && _port.isEmpty) {
      _ipaddress = dotenv.env['IPADDRESS']!;
      _port = dotenv.env['PORT']!;
    }
    return 'http://$_ipaddress:$_port/';
  }
}

class UserGender {
  List<String> genderOptions = [
    'Prefer not to say',
    'Male',
    'Female',
    'Others'
  ];
}

class FormatDate {
  String formatDateSQL(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  DateTime formatDateFromSQL(String date) {
    return DateFormat('M/d/yyyy').parse(date);
  }

  DateTime formatDatePV(String date) {
    return DateFormat('dd-MM-yyyy').parse(date);
  }
}

class DeviceInfo {
    Future<String> getDeviceName() async {
    Map deviceInfo = (await DeviceInfoPlugin().deviceInfo).data;
    // String? brand = deviceInfo['brand'];
    // String? model = deviceInfo['model'];
    // String name = deviceInfo['name'];
    // String name = deviceInfo['name'] ?? deviceInfo['platform'] ?? deviceInfo['computerName'] ?? deviceInfo['product'];
    String name = deviceInfo['name'] ??
        deviceInfo['platform'] ??
        deviceInfo['computerName'] ??
        deviceInfo['product'];
    // print(deviceInfo);
    return name;
  }
}