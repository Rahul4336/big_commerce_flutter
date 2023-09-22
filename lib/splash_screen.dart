import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:big_commerce/store_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class splash_screen extends StatefulWidget with WidgetsBindingObserver {
  @override
  State<splash_screen> createState() => _splash_screenState();
}

class _splash_screenState extends State<splash_screen> with WidgetsBindingObserver{
  final String dialogimg = 'assets/dialog.svg';
  SharedPreferences? sharedPrefs;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkAppVersion();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){
      checkAppVersion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget svglogo =Image.asset(
      'assets/splash.gif',
      height: 80.0,
      width: 80.0,
    );

    // return AnnotatedRegion<SystemUiOverlayStyle>(
    // value: SystemUiOverlayStyle.dark, // CHANGE FOR IOS Here

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.red,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(child: Container(child: svglogo)),
      ),
    );
  }

  void checkAppVersion() async {
    sharedPrefs = await SharedPreferences.getInstance();
    var response = await http.get(Uri.parse(store_class.base_url + "checkappversion/1.5"));
    var data = json.decode(response.body);

    if (data['appupdate'] == false) {
      SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

      String? permVerify = sharedPrefs.getString("perm_verify");
      String? tempVerify = sharedPrefs.getString("temp_verify");

      if (permVerify?.toLowerCase() == "true") {
        verifyPermToken();
      }

      if (tempVerify?.toLowerCase() == "true") {
        verifyTempToken();
      }

      if (!sharedPrefs.containsKey("perm_verify") || !sharedPrefs.containsKey("temp_verify")) {
        getTempToken();
      }
    }
    else{
      showUpdateDialog();
    }
  }

  void verifyTempToken() async {
    sharedPrefs = await SharedPreferences.getInstance();
    http.Client client = http.Client();
    http.Response response = await client.get(
      Uri.parse("${store_class.base_url}checkdtoken"),
      headers: {
        "dtoken": sharedPrefs?.getString("dtoken") ?? "",
      },
    );

    print(sharedPrefs?.getString("dtoken"));

    if (response.statusCode == 200) {
      Timer(const Duration(seconds: 0),(){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyMainPage(),));
      });
    }
    else {
      getTempToken();
    }
  }

  void verifyPermToken() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

    final url = Uri.parse('${store_class.base_url}user');
    final headers = <String, String>{
      'dtoken': sharedPrefs.getString('dtoken') ?? '',
    };

    print(sharedPrefs.getString("dtoken"));

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        Timer(const Duration(seconds: 3),(){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyMainPage(),));
        });
      }
      else
      {
        getTempToken();
      }
    } catch (error) {
      //
    }
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  Future<String?> getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.utsname.machine;
    }
    return null;
  }

  void showUpdateDialog() {
    final Widget svgdialog = SvgPicture.asset(dialogimg);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Center(child: Text('Update Available')),
          content: ListView(
            shrinkWrap: true,
            children: [
              Container(
                child: Center(child: Container(
                    width: 70,
                    height: 70,
                    child: svgdialog,)),
              ),
              SizedBox(
                height: 20,
              ),
              Text('The version of this App is no longer supported. Kindly update the App',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
              SizedBox(
                height: 20,
              ),  ElevatedButton(
                onPressed: () {
                  callStore();
                  Navigator.pop(context);
                },
                child: Text(
                  'UPDATE',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Set the background color to red
                ),
              ),
            ]
          ),);
      },);
  }

  void getTempToken() async {
    String? deviceName = await getDeviceName();
    String? deviceId = await _getId();

    Map<String, dynamic> requestBody = {
      "deviceid": deviceId,
      "devicename": deviceName,
    };

    String url = "${store_class.base_url}generatedtoken";

    String requestBodyJson = json.encode(requestBody);

    http.Response response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: requestBodyJson);

    if (response.statusCode == 200) {
      String responseBody = response.body;
      Map<String, dynamic> responseJson = json.decode(responseBody);

      SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
      sharedPrefs.setString("dtoken", responseJson["dtoken"]);
      sharedPrefs.setString("temp_verify", "true");
      sharedPrefs.setString("perm_verify", "false");

      verifyTempToken();
    }
    else {
      //
    }
  }

  void callStore()
  {
    if (Platform.isAndroid || Platform.isIOS) {
      final appId = Platform.isAndroid ? 'mo.ze.bcomm.big_commerce' : 'mo.ze.bcomm.big_commerce';
      final url = Uri.parse(
        Platform.isAndroid
            ? "market://details?id=$appId"
            : "https://apps.apple.com/app/id$appId",
      );
      launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}