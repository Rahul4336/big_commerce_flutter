import 'package:big_commerce/store_class.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:big_commerce/add_new_address.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'add_new_address.dart';

class address_list extends StatefulWidget {
  address_list_State createState() => address_list_State();
}

class address_list_State extends State<address_list>
    with WidgetsBindingObserver {
  List<dynamic> data = [];
  int selectedIndex = -1;
  bool isEmpview = false;
  bool islistview = false;
  bool isLoading = false;
  bool isEditLayout = true;
  bool isRefresh = false;
  bool isDeliverButton=false;
  String? addressuid;
  bool isDeliveringToAddress = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getAddressList();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getAddressList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Visibility(
              visible: isEmpview,
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'SAVE YOUR ADDRESS NOW',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 57,
                        height: 57,
                        child: Image.asset('assets/shopadd.png'),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Add your home and office address and enjoy faster checkout',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          store_class.isUpdateAddress = false;

                          bool refresh = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => add_new_address()));

                          if (refresh) {
                            getAddressList();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.red),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.red),
                              SizedBox(width: 5),
                              Text(
                                'Add New Address',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(
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
                            Navigator.pop(context);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(15),
                            child: Icon(Icons.arrow_back),
                          ),
                        ),
                        const Text(
                          'Select Delivery Address',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async{
                    store_class.isUpdateAddress = false;
                    var refresh = await Navigator.push<bool?>(context, MaterialPageRoute(builder: (context) => add_new_address())) ?? false;
                    if (refresh) {
                      getAddressList();
                    }
                    else{
                      getAddressList();
                    }
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    color: const Color(0xFFFFF2F1),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 5),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: Image.asset('assets/addsquare.png'),
                          ),
                        ),
                        const Text(
                          'ADD NEW ADDRESS',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Stack(
                    children: [
                      Visibility(
                        visible: islistview,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final item = data[index];
                            final full_name = item['full_name'];
                            final address = item['address'];
                            final uid = item['uid'];
                            final ccode = item['ccode'];
                            final phone = item['phone'];
                            final pincode = item['pincode'];
                            final city = item['city'];
                            final state = item['state'];
                            final landmark = item['landmark'];
                            final address_type = item['address_type'];

                            if(addressuid==uid){
                              checkInitial(uid);
                              selectedIndex = index;
                            }

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  addressuid=uid;
                                  selectedIndex = index;
                                  isEditLayout = true;
                                  checkDeliveringToAddress();
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.all(5),
                                padding: EdgeInsets.all(10),

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: selectedIndex == -1 ? Colors.white : (selectedIndex == index ? Color(0xFFE4E4E4) : Colors.white),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 5),

                                    Row(children: [
                                      Expanded(
                                        flex: 3,
                                        child:  Text(
                                          full_name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),),

                                      Visibility(
                                          visible:
                                          selectedIndex == index &&
                                              isEditLayout,
                                          child: Expanded(

                                            child: InkWell(
                                                onTap: (){
                                                  showAddressDetail(context,full_name,address_type,
                                                      address,
                                                      pincode,phone,landmark,state,city);
                                                },
                                                child: Align(
                                                    alignment: Alignment.topRight,

                                                    child: Image.asset('assets/more.png',width: 30,height: 30,)
                                                )
                                            ),
                                          )
                                      ),

                                      Visibility(
                                          visible:
                                          selectedIndex == index &&
                                              isEditLayout,
                                          child: Expanded(

                                            child: InkWell(
                                                onTap: (){
                                                  showAddressDetail(context,full_name,address_type,
                                                      address,
                                                  pincode,phone,landmark,state,city);
                                                },
                                                child: Align(
                                                    alignment: Alignment.topRight,
                                                    child: Image.asset('assets/select_addr.png',width: 30,height: 30,))),)
                                      ),


                                    ],),

                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Image.asset('assets/mobile.png',
                                            width: 12, height: 12),
                                        SizedBox(width: 2),
                                        Text(
                                          phone,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      address +
                                          "\n" +
                                          state +
                                          " | " +
                                          city,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            pincode,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible:
                                          selectedIndex == index &&
                                              isEditLayout,
                                          child: Expanded(
                                            flex: 2,
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .center,
                                              children: [
                                                InkWell(
                                                  onTap: () async {
                                                    store_class.isUpdateAddress = true;
                                                    store_class.address_uid = uid;
                                                    bool refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => add_new_address()));

                                                    if (refresh) {
                                                      getAddressList();
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                    EdgeInsets.only(
                                                        left: 5),
                                                    child: Row(
                                                      children: [
                                                        Image.asset(
                                                          'assets/edit.png',
                                                          width: 15,
                                                          height: 15,
                                                        ),
                                                        SizedBox(
                                                            width: 5),
                                                        Text(
                                                          'Edit',
                                                          style:
                                                          TextStyle(
                                                            fontSize: 11,
                                                            color: Colors
                                                                .black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    showRemoveAddressDialog(
                                                        context, uid);
                                                  },
                                                  child: Container(
                                                    padding:
                                                    EdgeInsets.only(
                                                        right: 25),
                                                    child: Row(
                                                      children: [
                                                        Image.asset(
                                                          'assets/trash.png',
                                                          width: 15,
                                                          height: 15,
                                                        ),
                                                        SizedBox(
                                                            width: 5),
                                                        const Text(
                                                          'Remove',
                                                          style:
                                                          TextStyle(
                                                            fontSize: 11,
                                                            color: Colors
                                                                .black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding:
                                          EdgeInsets.only(right: 5),
                                          child: Text(
                                            address_type.toUpperCase(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              color: Colors.teal,
                                            ),
                                          ),
                                        ),
                                        
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3.0,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),

                Visibility(
                  visible: isDeliverButton,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10,bottom: 5,top: 5),
                    child: Container(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: isDeliveringToAddress ? null : () async{
                          if(selectedIndex==-1){
                            Fluttertoast.showToast(msg: "Please select your order delivery address", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.BOTTOM, backgroundColor: Colors.white60, textColor: Colors.black,);
                          }
                          else{
                            if (addressuid != null) {
                              var sharedPrefs = await SharedPreferences.getInstance();
                              sharedPrefs.setString("address_id", addressuid!);
                              sharedPrefs.setString("delivery_address", "true");

                              Future.delayed(Duration.zero, () {
                                Navigator.pop(context,true);
                              });
                            } else {
                              Fluttertoast.showToast(msg: "Oops! unable to fetch address. Please select address", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.BOTTOM, backgroundColor: Colors.white60, textColor: Colors.black,);

                            }

                          }

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          isDeliveringToAddress ? 'DELIVERING TO THIS ADDRESS' : 'DELIVER TO THIS ADDRESS',
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getAddressList() async {
    var sharedPrefs = await SharedPreferences.getInstance();
    addressuid=sharedPrefs.getString("address_id") ?? "false";

    setState(() {
      isRefresh = true;
      isLoading = true;
      islistview = false;
      isEmpview = false;
      isDeliverButton=false;
      selectedIndex = -1;
    });

    final headers = {
      "dtoken": sharedPrefs.getString("dtoken") ?? "",
    };

    final response = await http.get(
      Uri.parse('${store_class.base_url}user/address'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        islistview = true;
        isLoading = false;
        isEmpview = false;
        data = responseData['Data'];
      });
    } else if (response.statusCode == 404) {
      setState(() {
        isEmpview = true;
        islistview = false;
        isLoading = false;
        isDeliverButton=false;
      });
      var sharedPrefs = await SharedPreferences.getInstance();
      sharedPrefs.setString("address", "false");
      sharedPrefs.setString("delivery_address", "false");
    }
    else {
      isLoading = false;
      islistview = false;
      isEmpview = false;
      isDeliverButton=false;
      print('getAddressListError: ${response.statusCode}');
    }
  }

  Future<void> deleteAddress(String uid) async {
    var sharedPrefs = await SharedPreferences.getInstance();
    final headers = {
      "dtoken": sharedPrefs.getString("dtoken") ?? "",
    };

    final response = await http.delete(
      Uri.parse("${store_class.base_url}user/address/$uid"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      getAddressList();
    }
    else {
    }
  }

  void showRemoveAddressDialog(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/rem_address.png',
                  width: 100,
                  height: 70,
                ),
                SizedBox(height: 10),
                Text(
                  'Are you sure?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'This address will be deleted from your address list.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      deleteAddress(uid);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Yes, delete',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> checkInitial(String uid) async {
    var sharedPrefs = await SharedPreferences.getInstance();
    String storedaddressuid = sharedPrefs.getString("address_id") ?? 'false';

    setState(() {
      if(storedaddressuid == uid){
        isDeliverButton=true;
        isDeliveringToAddress = true;
      }
    });
  }


  Future<void> checkDeliveringToAddress() async {
    var sharedPrefs = await SharedPreferences.getInstance();
    String storedaddressuid = sharedPrefs.getString("address_id") ?? 'false';


    setState(() {
      if (addressuid == storedaddressuid) {
        if (selectedIndex == -1){
          isDeliverButton=false;
        }
        else{
          isDeliverButton=true;
          isDeliveringToAddress = true;
        }
      }
      else {
        isDeliverButton=true;
        isDeliveringToAddress = false;
      }
    });
  }

  void showAddressDetail(BuildContext context ,full_name, address_type, address, pincode, phone, landmark, state, city){
    showModalBottomSheet(context: context,
        builder:  (BuildContext context){
          return Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            height: 300,
            child: Column(
              children: [
                Column(
                  children: [
                    Image.asset('assets/select_addr.png',width: 50,height: 50,),
                    const SizedBox(height: 5,),
                      Text('Your '+address_type+' address details',
                        style: TextStyle(fontSize: 14,color: Colors.black, fontWeight: FontWeight.w500),),
                    const SizedBox(height: 10,),
                    const Divider(height: 1,),
                    const SizedBox(height: 10,),
                    Text(full_name,style: TextStyle(fontSize: 23,color: Colors.grey,fontWeight: FontWeight.w600),),
                    const SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Image.asset('assets/sd_call.png',width: 20,height: 20,),
                      const SizedBox(width: 5,),
                      Text(phone,style: TextStyle(color: Colors.green),),
                    ],),
                    const SizedBox(height: 10,),
                    Text(address,style: TextStyle(fontSize: 13,color: Colors.black,),
                      textAlign: TextAlign.center,),
                    const SizedBox(height: 5,),
                    Text(city+", "+state+" | "+pincode,style: TextStyle(fontSize: 13,color: Colors.black,),
                      textAlign: TextAlign.center,),
                    const SizedBox(height: 5,),
                    Text(landmark,style: TextStyle(fontSize: 12,color: Colors.grey),),
                  ],
                ),
              ],
            ),
          );
        }
    );
  }
}
