import 'package:big_commerce/add_new_address.dart';
import 'package:big_commerce/address_list.dart';
import 'package:big_commerce/categories_page.dart';
import 'package:big_commerce/myorders_page.dart';
import 'package:big_commerce/register_bottom_sheet.dart';
import 'package:big_commerce/splash_screen.dart';
import 'package:big_commerce/store_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: splash_screen(),
    );
  }
}

class MyMainPage extends StatefulWidget {

  _MyMainPageState createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  int myindex = 0;
  bool isRegistered=false;
  List<Widget> widgetlist = [Home_screen(key: GlobalKey<_Home_screenState>()),
    categories_page(),
    myorders_page(),
    myprofile_page(key: GlobalKey<_myprofile_pageState>()),];

  void changeTab(int index) {
    setState(() {
      myindex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {


    // return AnnotatedRegion<SystemUiOverlayStyle>(
    //     value: SystemUiOverlayStyle.dark, // CHANGE FOR IOS Here

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark, // Set the status bar icons to be displayed as dark
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: IndexedStack(children: widgetlist, index: myindex),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: Colors.red,
          unselectedItemColor: Color(0xFF808080),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          onTap: (index) {
            if(index ==0){
            setState(() {
            myindex = index;
            });

            final homepageKey =
            widgetlist[myindex].key as GlobalKey<_Home_screenState>;
            homepageKey.currentState?.checkRegistrationStatus();

            }
            else if (index == 2) {
              store_class.opentype = 'order';
              getMyCartPageWidget().then((value) {
                if (value) {
                  setState(() {
                    myindex = index;
                  });
                } else {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    isDismissible: false,
                    enableDrag: false,
                    builder: (BuildContext context) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: BottomSheetWidget(onTabChanged: changeTab),
                        ),
                      );
                    },
                  );
                }
              });
            }
            else if(index ==3){
              setState(() {
                myindex = index;
              });

              final profilePageKey =
              widgetlist[myindex].key as GlobalKey<_myprofile_pageState>;
              profilePageKey.currentState?.updateUI();

            }
            else {
              setState(() {
                myindex = index;
              });
            }
          },

          currentIndex: myindex,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Image.asset(
                  'assets/home.png',
                  width: 21,
                  height: 21,
                ),
              ),
              activeIcon: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Image.asset(
                  'assets/home_selected.png',
                  width: 21,
                  height: 21,
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Image.asset(
                  'assets/category.png',
                  width: 21,
                  height: 21,
                ),
              ),
              activeIcon: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Image.asset(
                  'assets/category_selected.png',
                  width: 21,
                  height: 21,
                ),
              ),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Image.asset(
                  'assets/orders.png',
                  width: 21,
                  height: 21,
                ),
              ),
              activeIcon: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Image.asset(
                  'assets/order_selected.png',
                  width: 21,
                  height: 21,
                ),
              ),
              label: 'My Orders',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Image.asset(
                  'assets/profile.png',
                  width: 21,
                  height: 21,
                ),
              ),
              activeIcon: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Image.asset(
                  'assets/profile_selected.png',
                  width: 21,
                  height: 21,
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> getMyCartPageWidget() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    String? permVerify = sharedPrefs.getString("perm_verify");
    return permVerify?.toLowerCase() == "true";
  }

}



/////////////////////////////////HOME PAGE///////////////////////////////////////////


class Home_screen extends StatefulWidget {
  Home_screen({Key? key}) : super(key: key);
  _Home_screenState createState() => _Home_screenState();
}

class _Home_screenState extends State<Home_screen> with WidgetsBindingObserver  {
  bool isSignuptoaddlayout = true;
  bool isDeliveringtolocationlayout = false;
  bool isAddAddresslayout = false;
  SharedPreferences? sharedPrefs;
  int myindex = 0;
  @override
  void initState() {
    checkRegistrationStatus();
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkRegistrationStatus();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/search.png', // Replace with your image path
                          width: 18,
                          height: 18,
                        ),
                      ),
                      Text(
                        'Search product name or id',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 15, left: 15),
                        child: Image.asset(
                          'assets/voice.png', // Replace with your image path
                          width: 18,
                          height: 18,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/heart.png', // Replace with your image path
                          width: 18,
                          height: 18,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/shoppingcart.png', // Replace with your image path
                          width: 18,
                          height: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                height: 45,
                color: Color(0xFFEEF8F0),
                child: Stack(
                  children: [
                    Visibility(
                      visible: isSignuptoaddlayout, // Set visibility based on your logic
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/add_addres.gif', // Replace with your image path
                              width: 30,
                              height: 30,
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                store_class.opentype ='home';
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  isDismissible: false,
                                  enableDrag: false,
                                  builder: (BuildContext context) {
                                    return SingleChildScrollView(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context).viewInsets.bottom,
                                        ),
                                        child: BottomSheetWidget(onTabChanged: changeTab),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'Signup to add location and address details',
                                    style: TextStyle(
                                      color: Color(0xFF424242),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Image.asset(
                                      'assets/arrow.png',
                                      height: 18,
                                      width: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                    Visibility(
                      visible: isDeliveringtolocationlayout, // Set visibility based on your logic
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            child: Image.asset(
                              'assets/home_loc.gif', // Replace with your image path
                              height: 50,
                              width: 50,
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  'Delivering to Faridabad - 121012',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Image.asset(
                                    'assets/arrow.png', // Replace with your image path
                                    height: 12,
                                    width: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: isAddAddresslayout, // Set visibility based on your logic
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/add_addres.gif', // Replace with your image path
                              width: 30,
                              height: 30,
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                final route = MaterialPageRoute(builder: (_) => add_new_address());
                                Future.delayed(Duration.zero, () {
                                  Navigator.push(context, route);
                                });
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'Add delivery location and address details',
                                    style: TextStyle(
                                      color: Color(0xFF424242),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Image.asset(
                                      'assets/arrow.png',
                                      height: 18,
                                      width: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  void changeTab(int index) {
    setState(() {
      myindex = index;
      checkRegistrationStatus();
    });
  }

  void checkRegistrationStatus() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    String? permVerify = sharedPrefs.getString("perm_verify");
    String? address = sharedPrefs.getString("address");

    setState(() {
      if(permVerify?.toLowerCase() == "true"){
        if(address?.toLowerCase() == "true"){
          isSignuptoaddlayout =false;
          isDeliveringtolocationlayout = true;
          isAddAddresslayout = false;
        }
        else{
          isSignuptoaddlayout =false;
          isDeliveringtolocationlayout = false;
          isAddAddresslayout = true;
        }
      }
      else{
        isSignuptoaddlayout =true;
        isDeliveringtolocationlayout = false;
        isAddAddresslayout = false;
      }

    });
  }

}














/////////////////////////////////////MY PROFILE/////////////////////////////////////////

class myprofile_page extends StatefulWidget {
  myprofile_page({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _myprofile_pageState();

}

class _myprofile_pageState extends State<myprofile_page> {
  String? mobno, ccode,permVerify,tempVerify;
  bool isNotRegisteredLayout = true;
  bool isRegisteredLayout = false;
  int myindex = 0;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    updateUI();
  }

  void updateUI() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    setState(() {
      mobno = sharedPrefs.getString("mobno");
      ccode = sharedPrefs.getString("ccode");
      permVerify = sharedPrefs.getString("perm_verify");
      tempVerify = sharedPrefs.getString("temp_verify");

      if (permVerify == 'true') {
        isRegisteredLayout = true;
        isNotRegisteredLayout = false;
      } else {
        isRegisteredLayout = false;
        isNotRegisteredLayout = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.zero,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              child: Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'My profile',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 2,
            ),

            Stack(
                children:[
                  Visibility(
                    visible: isRegisteredLayout,
                    child: Column(
                      children: [
                        Container(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 90,
                              color: Colors.white,
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: (){
                                      selectPhotoSheet(context);
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          child: _selectedImage == null ?
                                          ClipOval(
                                            child: Image.asset(
                                              'assets/men.png',
                                              width: 70,
                                              height: 70,
                                            ),
                                          )
                                              :
                                          ClipOval(
                                            child: Image.file(
                                              _selectedImage!,
                                              fit: BoxFit.cover,
                                              width: 70,
                                              height: 70,
                                            ),
                                          ),

                                        ),


                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFF1F1F1),
                                            ),
                                            child: Image.asset(
                                              'assets/camera.png',
                                              width: 16,
                                              height: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "+$ccode-$mobno",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/verify.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 7,
                        ),
                        Container(
                          height: 53,
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                padding: EdgeInsets.all(10),
                                icon: Image.asset(
                                  'assets/viewed_products.png', // Replace with your image path
                                  width: 22,
                                  height: 22,
                                ),
                                onPressed: () {
                                  // Add your favorite functionality here
                                },
                              ),
                              Text(
                                'My Viewed Products',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Container(
                          height: 53,
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                padding: EdgeInsets.all(10),
                                icon: Image.asset(
                                  'assets/heart_black.png', // Replace with your image path
                                  width: 22,
                                  height: 22,
                                ),
                                onPressed: () {
                                  // Add your favorite functionality here
                                },
                              ),
                              Text(
                                'My Liked Products',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        InkWell(
                          onTap: (){
                            final route = MaterialPageRoute(builder: (_) => address_list());
                            Navigator.push(context, route);
                          },
                          child: Container(
                            height: 53,
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.all(10),
                                  icon: Image.asset(
                                    'assets/location.png', // Replace with your image path
                                    width: 22,
                                    height: 22,
                                  ),
                                  onPressed: () {
                                    // Add your favorite functionality here
                                  },
                                ),
                                Text(
                                  'Manage your Address',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        InkWell(
                          onTap: (){
                            _showLogoutBottomSheet(context);
                          },
                          child: Container(
                            height: 53,
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.all(10),
                                  icon: Image.asset(
                                    'assets/logout.png', // Replace with your image path
                                    width: 22,
                                    height: 22,
                                  ),
                                  onPressed: () {
                                    // Add your favorite functionality here
                                  },
                                ),
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                  ),

                  // NOT REGISTERED

                  InkWell(
                    onTap: (){
                      store_class.opentype="profile";
                      showRegisterSheet();
                    },
                    child: Visibility(
                      visible: isNotRegisteredLayout,
                      child: Column(
                        children: [
                          Container(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 90,
                                color: Colors.white,
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        Image.asset(
                                          'assets/profile_img.gif',
                                          fit: BoxFit.cover,
                                          width: 70,
                                          height: 70,
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFF1F1F1),
                                            ),
                                            child: Image.asset(
                                              'assets/camera.png',
                                              width: 16,
                                              height: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 16.0),
                                            child: SizedBox(
                                              width: 100,
                                              height: 30,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  store_class.opentype="profile";
                                                  showRegisterSheet();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                child: Text(
                                                  'Sign up',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                        ),
                                        SizedBox(height: 8,),
                                        Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            'Signup to add your profile details',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),


                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 7,
                          ),
                          Container(
                            height: 53,
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.all(10),
                                  icon: Image.asset(
                                    'assets/viewed_products.png', // Replace with your image path
                                    width: 22,
                                    height: 22,
                                  ),
                                  onPressed: () {
                                    // Add your favorite functionality here
                                  },
                                ),
                                Text(
                                  'My Viewed Products',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),

                    ),
                  ),

                ]
            ),


          ],
        ),
      ),
    );
  }

  void changeTab(int index) {
    setState(() {
      myindex = index;
      updateUI();
    });
  }


  void logout() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString("temp_verify", "true");
    sharedPrefs.setString("perm_verify", "false");

    final route = MaterialPageRoute(builder: (_) => splash_screen());
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacement(context, route);
    });
  }


  void showRegisterSheet(){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: BottomSheetWidget(onTabChanged: changeTab),
          ),
        );
      },
    );
  }

  void _showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,

      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Image.asset(
                    'assets/close.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 0.5,
                color: Colors.grey,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black),
                        ),
                        padding: EdgeInsets.all(14),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        logout();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.red,
                        ),
                        padding: EdgeInsets.all(15),
                        child: Center(
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  void _showPermissionRequiredBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Image.asset(
                    'assets/close.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),

              Row(
                children: [
                  Image.asset(
                    'assets/storage.png',
                    width: 54.0,
                    height: 47.0,
                  ),

                  SizedBox(width: 20,),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Allow Storage Access',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        'We need to access your '+"phone's"+' storage\n'
                            'to select image from gallery and camera\n',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 10.0),

              Container(
                color: Colors.grey,
                height: 0.5,
              ),

              SizedBox(height: 20.0),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black),
                        ),
                        padding: EdgeInsets.all(14),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 15),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {

                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.red,
                        ),
                        padding: EdgeInsets.all(15),
                        child: Center(
                          child: Text(
                            'Allow Permission',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  void selectPhotoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,

      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Image.asset(
                    'assets/close.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Select Profile Picture',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 0.5,
                color: Colors.grey,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                      _getImageFromGallery();
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/galleryadd.png',
                          width: 36,
                          height: 36,
                        ),
                        Text(
                          'Gallery',
                          style: TextStyle(
                              fontSize: 12
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 25,),

                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                      _captureImageFromCamera();
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/cameraadd.png',
                          width: 36,
                          height: 36,
                        ),
                        Text(
                            'Camera',
                            style: TextStyle(fontSize: 12))

                      ],
                    ),
                  ),

                ],
              ),
            ],

          ),

        );
      },
    );
  }

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery,
      maxWidth: 250,
      maxHeight: 250,);

    setState(() {
      if (pickedImage != null) {
        _selectedImage = File(pickedImage.path);
      }
      else {
        print('No image selected.');
      }
    });
  }

  Future<void> _captureImageFromCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera,
      maxWidth: 250,
      maxHeight: 250,);

    setState(() {
      if (pickedImage != null) {
        _selectedImage = File(pickedImage.path);
      }
      else {
        print('No image captured.');
      }
    });
  }
}

