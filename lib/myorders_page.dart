import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class myorders_page extends StatefulWidget{

  _myorders_pageState createState() => _myorders_pageState();
}

class _myorders_pageState extends State<myorders_page> {
  File? imageFile;
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Card(
          margin: EdgeInsets.zero,
          color: Colors.white,
          child: Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'My Orders',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}