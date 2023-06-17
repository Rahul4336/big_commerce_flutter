import 'package:big_commerce/store_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class add_new_address extends StatefulWidget {
  @override
  _add_new_addressState createState() => _add_new_addressState();
}

class _add_new_addressState extends State<add_new_address> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController(text: '');
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController(text: '');
  final TextEditingController _cityController = TextEditingController(text: '');
  final TextEditingController _stateController = TextEditingController(text: '');
  final TextEditingController _landmarkController = TextEditingController();


  String _addressType="Home";
  List<dynamic> data = [];
  int selectedIndex = 0;
  String? mobno, ccode;

  @override
  void initState() {
    super.initState();
    updateUI();
    _pincodeController.addListener(() {
      if (_pincodeController.text.length > 3) {
        if (!store_class.isUpdateAddress) {
          getDataFromPinCode(_pincodeController.text);
        }
      }
    });

    if (store_class.isUpdateAddress) {
      getAddress();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              margin: EdgeInsets.zero,
              color: Colors.white,
              child: SizedBox(
                height: 50,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Handle back button tap
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Icon(Icons.arrow_back),
                      ),
                    ),
                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),


            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        color: const Color(0xFFFFF2F1),
                        child: Row(children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15,right: 5),
                            child: SizedBox(
                                width: 24,
                                height: 24,
                                child: Image.asset('assets/info.png'),
                            ),
                          ),

                          const Text('Order will be deliver to this address',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),

                        ],),

                      ),

                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [

                              Column(children: [
                                Row(
                                  children: [
                                    SizedBox(
                                        width: 24, height: 24,
                                        child: Image.asset('assets/call.png')
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text(
                                        'Contact Details',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 5,),

                                Padding(
                                  padding: const EdgeInsets.only(left: 28),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width: 20, height: 20,
                                          child: Image.asset('assets/verify.png')
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(
                                          "+$ccode-$mobno",
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              ],),

                              const SizedBox(height: 10,),

                              Row(
                                children: [
                                  Expanded(child:   TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Enter name',
                                      labelStyle: TextStyle(fontSize: 15),
                                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                                    ),

                                    style: const TextStyle(fontSize: 14),

                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a name';
                                      }
                                      return null;
                                    },
                                  ),),

                                  SizedBox(width: 20,),

                                  Expanded(child: TextFormField(
                                    controller: _phoneNumberController,
                                    decoration: const InputDecoration(
                                      labelText: 'Enter phone no',
                                      labelStyle: TextStyle(fontSize: 15),
                                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                                    ),

                                    style: const TextStyle(fontSize: 14),
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a phone number';
                                      }
                                      return null;
                                    },
                                  ),),

                                ],
                              ),


                              const SizedBox(height: 20),

                              Text('Choose Address Type',
                                style: TextStyle(fontSize: 15,
                                color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _addressType = 'Home';
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Radio(
                                          value: 'Home',
                                          groupValue: _addressType,
                                          onChanged: (value) {
                                            setState(() {
                                              _addressType = value!;
                                            });
                                          },
                                        ),
                                        Text(
                                          'Home',
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _addressType = 'Office';
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Radio(
                                          value: 'Office',
                                          groupValue: _addressType,
                                          onChanged: (value) {
                                            setState(() {
                                              _addressType = value!;
                                            });
                                          },
                                        ),
                                        const Text(
                                          'Office',
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _addressType = 'Other';
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Radio(
                                          value: 'Other',
                                          groupValue: _addressType,
                                          onChanged: (value) {
                                            setState(() {
                                              _addressType = value!;
                                            });
                                          },
                                        ),
                                        const Text(
                                          'Other',
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              ],
                            ),
                            const SizedBox(height: 10,)
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [

                              Row(
                                children: [
                                  SizedBox(
                                      width: 24, height: 24,
                                      child: Image.asset('assets/locationadd.png')
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Text(
                                      'Address Details',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10,),


                              TextFormField(
                                controller: _pincodeController,
                                decoration:
                                const InputDecoration(
                                    labelText: 'Enter Pincode',
                                  labelStyle: TextStyle(fontSize: 15),
                                ),

                                style: const TextStyle(fontSize: 14),
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a pincode';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _addressController,
                                decoration: const InputDecoration(
                                    labelText: 'Enter Complete Address',
                                  labelStyle: TextStyle(fontSize: 15),),

                                style: const TextStyle(fontSize: 14),

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a complete address';
                                  }
                                  return null;
                                },
                              ),

                              Row(
                                children: [
                                  Expanded(child: TextFormField(
                                    controller: _cityController,
                                    decoration:
                                    const InputDecoration(labelText: 'Enter City',
                                      labelStyle: TextStyle(fontSize: 15),),

                                    style: const TextStyle(fontSize: 14),

                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a city';
                                      }
                                      return null;
                                    },
                                  ),),

                                  SizedBox(width: 20,),

                                  Expanded(child:   TextFormField(
                                    controller: _stateController,

                                    decoration:
                                    const InputDecoration(labelText: 'Enter State',
                                      labelStyle: TextStyle(fontSize: 15),),

                                    style: const TextStyle(fontSize: 14),

                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a state';
                                      }
                                      return null;
                                    },
                                  ),),

                                ],
                              ),

                              TextFormField(
                                controller: _landmarkController,
                                decoration:
                                const InputDecoration(labelText: 'Enter Landmark',
                                  labelStyle: TextStyle(fontSize: 15),),

                                style: const TextStyle(fontSize: 14),

                              ),

                              SizedBox(height: 20,),

                              Container(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() == true) {
                                      if(store_class.isUpdateAddress){
                                        updateAddress();
                                      }
                                      else {
                                        addNewAddress();
                                      }
                                    }
                                  },
                                  child: const Text('Submit'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addNewAddress() async {
    SharedPreferences sharedPrefs= await SharedPreferences.getInstance();
    var requestBody = {
      'full_name':_nameController.text,
      'ccode': ccode,
      'phone': _phoneNumberController.text,
      'pincode':_pincodeController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'state':_stateController.text,
      'landmark': _landmarkController.text,
      'address_type': _addressType,
    };

    try {
      var response = await http.post(
        Uri.parse("${store_class.base_url}user/address"),
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json',
          "dtoken": sharedPrefs.getString("dtoken") ?? "",
        },
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Address Added", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.BOTTOM, backgroundColor: Colors.white60, textColor: Colors.black,);

        sharedPrefs = await SharedPreferences.getInstance();
        sharedPrefs.setString("address", "true");
        setState(() {
          finish();
        });
      }
      else {
        print('POST request failed with status: ${response.statusCode}');
      }
    }
    catch (error) {
      print('Exception occurred: $error');
    }

  }

  Future<void> updateAddress() async{
    SharedPreferences sharedPrefs= await SharedPreferences.getInstance();
    var requestBody = {
      'full_name':_nameController.text,
      'ccode': ccode,
      'phone': _phoneNumberController.text,
      'pincode':_pincodeController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'state':_stateController.text,
      'landmark': _landmarkController.text,
      'address_type': _addressType,
    };

    try {
      var response = await http.put(
        Uri.parse("${store_class.base_url}user/address/${store_class.address_uid}"),
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json',
          "dtoken": sharedPrefs.getString("dtoken") ?? "",
        },
      );

      print(requestBody);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Address Updated", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.BOTTOM, backgroundColor: Colors.white60, textColor: Colors.black,);
        setState(() {
          finish();
        });
      } else {
        print('POST request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Exception occurred: $error');
    }
  }

  void finish() {
    Navigator.pop(context);
  }

  void updateUI() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    setState(() {
      mobno = sharedPrefs.getString("mobno");
      ccode = sharedPrefs.getString("ccode");
      _phoneNumberController.text=mobno!;
    });
  }

  Future<void> getDataFromPinCode(String pinCode) async {
    final response = await http.get(
      Uri.parse(store_class.postalURL + pinCode),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        data = responseData['PostOffice'];
        _stateController.text=data[0]['State'];
        _cityController.text=data[0]['District'];
        _addressController.text=data[0]['Name'];
      });
    }
    else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> getAddress() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    final headers = {
      "dtoken": sharedPrefs.getString("dtoken") ?? "",
    };

    final response = await http.get(
      Uri.parse("${store_class.base_url}user/address/${store_class.address_uid}"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        _stateController.text=responseData['state'];
        _cityController.text=responseData['city'];
        _addressController.text=responseData['address'];
        _nameController.text=responseData['full_name'];
        _phoneNumberController.text=responseData['phone'];
        _landmarkController.text=responseData['landmark'];
        _pincodeController.text=responseData['pincode'];
      });
    }
    else {
      print('Error: ${response.statusCode}');
    }
  }
}
