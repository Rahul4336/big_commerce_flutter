import 'package:big_commerce/store_class.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';


class BottomSheetWidget extends StatefulWidget {
  final Function(int) onTabChanged;

  const BottomSheetWidget({Key? key, required this.onTabChanged})
      : super(key: key);

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  bool isRegisterLayoutVisible = true;
  bool isOTPLayoutVisible = false;
  bool isCountryLayoutVisible = false;
  bool _isTimerRunning = false;
  Timer? _resendTimer;
  int _resendSeconds = 120;
  bool _isWidgetDisposed = false;
  bool isLoading = false;
  List<dynamic> countrylist = [];
  SharedPreferences? sharedPrefs;
  int selectedIndex = 0;

  TextEditingController textEditingController = TextEditingController();
  bool _validate = false;
  String otpValue='';


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Visibility(
            visible: isRegisterLayoutVisible,
            child: Container(
              color: Colors.white,
              height: 320,
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Image.asset(
                          'assets/close.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Sign Up to Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Please enter your mobile number to receive verification code',
                    style: TextStyle(
                      fontSize: 11.0,
                      color: Colors.black45,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Country',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Phone Number',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            fetchCountry();

                            setState(() {
                              isRegisterLayoutVisible = false;
                              isOTPLayoutVisible = false;
                              isCountryLayoutVisible = true;
                            });
                          },
                          child: Row(
                            children: [
                              Image.network(
                               store_class.countryflagpath,
                                width: 30.0,
                                height: 20.0,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                "+"+store_class.ccode,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0,
                                ),
                              ),
                              SizedBox(width: 5.0),
                              Image.asset(
                                'assets/arrowdown.png',
                                width: 20,
                                height: 20,
                              ),
                              SizedBox(width: 5.0),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 30.0,
                          child: TextField(
                            controller: textEditingController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                               // errorText: _validate ? 'Enter Phone No' : null,
                            ),
                            keyboardType: TextInputType.phone,
                            onChanged: (value) {
                              setState(() {
                               // _validate = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.only(right: 20.0),
                          child: Divider(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Divider(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          store_class.phno = textEditingController.text;
                          if (store_class.phno.isEmpty) {
                            Fluttertoast.showToast(
                              msg: "Please enter phone no",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.white60,
                              textColor: Colors.black,
                            );
                            // setState(() {
                            //   _validate = true;
                            // });
                          } else {
                            // setState(() {
                            //   _validate = false;
                            // });
                            sendOTP();
                            if (!_isTimerRunning) {
                              setState(() {
                                isRegisterLayoutVisible = false;
                                isOTPLayoutVisible = true;
                                isCountryLayoutVisible = false;

                                _isTimerRunning = true;
                                _resendSeconds = 120;
                                startResendTimer();
                              });
                            }

                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text('SEND OTP'),
                      )
                  ),
                  SizedBox(height: 20.0),
                  Center(
                    child: InkWell(
                      onTap: () {
                        print('by continue button');
                      },
                      child: Text(
                        'By continuing, you agree to our',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Terms and Conditions',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        ' and ',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: Colors.black45,
                        ),
                      ),
                      Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          //OTP LAYOUT

          Visibility(
            visible: isOTPLayoutVisible,
            child: Container(
              color: Colors.white,
              height: 320,
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Stack(
                            children: [
                              Visibility(
                                visible:
                                    _isTimerRunning, // Show timer if it's running
                                child: Container(
                                  child: Text(
                                    'Resend OTP in $_resendSeconds seconds',
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible:
                                    !_isTimerRunning, // Show button if timer is not running
                                child: GestureDetector(
                                  onTap: () {
                                    resendOTP();
                                    if (!_isTimerRunning) {
                                      setState(() {
                                        _isTimerRunning = true;
                                        _resendSeconds = 120;
                                        startResendTimer();
                                      });
                                    }
                                  },
                                  child: Text(
                                    'RESEND OTP',
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Image.asset(
                                  'assets/close.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 5.0),
                          child: Image.asset(
                            'assets/verify.png',
                            width: 24,
                            height: 24,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'OTP Sent To : ${store_class.phno}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {},
                    onCompleted: (value) {
                      otpValue=value;
                      verifyOTP();
                    },
                  ),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if(otpValue.isEmpty){
                          Fluttertoast.showToast(
                            msg: "Please enter OTP",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.white60,
                            textColor: Colors.black,
                          );
                        }
                        else{
                          verifyOTP();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text('VERIFY AND CONTINUE'),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/mobile.png', // Replace with your image path
                          width: 16,
                          height: 16,
                        ),
                        SizedBox(width: 2),
                        Center(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isRegisterLayoutVisible = true;
                                isOTPLayoutVisible = false;
                                isCountryLayoutVisible = false;

                                if (_isTimerRunning) {
                                  setState(() {
                                    _isTimerRunning = false;
                                    _resendSeconds = 0;
                                    _resendTimer?.cancel();
                                  });
                                }
                              });
                            },
                            child: Text(
                              'CHANGE NUMBER',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Center(
                    child: InkWell(
                      onTap: () {},
                      child: Text(
                        'By continuing, you agree to our',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Terms and Conditions',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        ' and ',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: Colors.black45,
                        ),
                      ),
                      Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          //Country Layout

          Visibility(
              visible: isCountryLayoutVisible,
              child: Container(
                color: Colors.white,
                height: 320,
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isRegisterLayoutVisible = true;
                              isOTPLayoutVisible = false;
                              isCountryLayoutVisible = false;
                            });

                          },
                          child: Image.asset(
                            'assets/backsquare.png',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Select your country',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),

                    Divider(
                      color: Colors.black45,
                      height: 1,
                    ),

                    SizedBox(height: 10.0),

                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: countrylist.length,
                        itemBuilder: (context, index) {
                          final item = countrylist[index];
                          final name = item['name'];
                          final ccode = item['ccode'];
                          final iconname = item['iconname'];

                          // Customize how you want to display the list item

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                                isRegisterLayoutVisible = true;
                                isOTPLayoutVisible = false;
                                isCountryLayoutVisible = false;
                                store_class.ccode=ccode;
                                store_class.countryflagpath= '${store_class.base_url}/static/country/$iconname';
                              });
                            },

                            child:Row(
                              children: [
                                Image.network(
                                  '${store_class.base_url}/static/country/$iconname',
                                  height: 20,
                                  width: 30,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(13),
                                  child: Text(
                                    name+" (+"+ccode+")",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          );

                        },


                      ),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }


  Future<void> resendOTP() async {
    var url =  Uri.parse("${store_class.base_url}user/resendotp");

    var requestBody = {
      'mobno': store_class.phno,
      'ccode': store_class.ccode,
    };

    var response = await http.post(
      url,
      body: jsonEncode(requestBody),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
    }
    else{
    }
  }

  Future<void> sendOTP() async {
    var url =  Uri.parse("${store_class.base_url}user/getstart");

    var requestBody = {
      'mobno': store_class.phno,
      'ccode': store_class.ccode,
    };

    var response = await http.post(
      url,
      body: jsonEncode(requestBody),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
    }
    else{
    }
  }


  Future<void> verifyOTP() async {
    var url =  Uri.parse("${store_class.base_url}user/verifyotp");

    var requestBody = {
      'otp':otpValue,
      'mobno': store_class.phno,
      'ccode': store_class.ccode,
    };

    var response = await http.post(
      url,
      body: jsonEncode(requestBody),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      String responseBody = response.body;
      Map<String, dynamic> responseJson = json.decode(responseBody);

      SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
      sharedPrefs.setString("dtoken", responseJson["token"]);
      sharedPrefs.setString("ccode", responseJson["ccode"]);
      sharedPrefs.setString("mobno", responseJson["mobno"]);
      sharedPrefs.setString("temp_verify", "false");
      sharedPrefs.setString("perm_verify", "true");

      if (store_class.opentype == 'order') {
         navigateToCartPage();
      }
      else if (store_class.opentype == 'profile') {
        navigateToProfilePage();
      }
      else if (store_class.opentype == 'home') {
        navigateToHomePage();
      }


    }
    else if(response.statusCode==400){
      Fluttertoast.showToast(
        msg: "Invalid OTP",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white60,
        textColor: Colors.black,
      );
    }
    else{
      Fluttertoast.showToast(
        msg: "Oops! something went wrong",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white60,
        textColor: Colors.black,
      );
    }
  }

  Future<void> fetchCountry() async {
    isLoading = true;
    sharedPrefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse("${store_class.base_url}user/country"),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      countrylist = jsonData['Data'];
      setState(() {
        isLoading = false;
      });
    } else {
      print('Failed to fetch data. Status code: ${response.statusCode}');
    }
  }

  void startResendTimer() {
    const oneSec = const Duration(seconds: 1);
    _resendTimer = Timer.periodic(oneSec, (Timer timer) {
      if (!_isWidgetDisposed) {
        setState(() {
          if (_resendSeconds < 1) {
            _isTimerRunning = false; // Timer has expired
            timer.cancel();
          } else {
            _resendSeconds--;
          }
        });
      }
    });
  }



  void navigateToCartPage() {
    if (!_isWidgetDisposed) {
      Navigator.of(context).pop();
      widget.onTabChanged(2);

    }
  }

  void navigateToProfilePage() {
    if (!_isWidgetDisposed) {
      Navigator.of(context).pop();
      widget.onTabChanged(3);
    }
  }

  void navigateToHomePage() {
    if (!_isWidgetDisposed) {
      Navigator.of(context).pop();
      widget.onTabChanged(0);
    }
  }

  @override
  void dispose() {
    _isWidgetDisposed = true;
    _resendTimer?.cancel();
    super.dispose();
  }
}
