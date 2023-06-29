import 'package:big_commerce/store_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class search_results extends StatefulWidget{
  search_results_State createState()=> search_results_State();
}

class search_results_State extends State<search_results>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Text(store_class.value),
        ],),
      ),
    );
  }

}