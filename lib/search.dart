import 'dart:async';

import 'package:big_commerce/store_class.dart';

import 'search_results.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart';

class search extends StatefulWidget {
  search_State createState() => search_State();
}

class search_State extends State<search> {
  TextEditingController textSearchController = TextEditingController();

  SpeechToText speech = SpeechToText();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Center(
                child: Container(
                  height: 50,
                  width: double.infinity,
                  margin: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 15, left: 15),
                        child: Image.asset(
                          'assets/search.png', // Replace with your image path
                          width: 18,
                          height: 18,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: textSearchController,
                          decoration: InputDecoration(
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14),
                            hintText: 'Search product name or id',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          store_class.value='Listening';
                          showSpeechDialog(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 15, left: 15),
                          child: Image.asset(
                            'assets/voice.png', // Replace with your image path
                            width: 18,
                            height: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Add your design here
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                height: 195,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent),
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        'Popular Searches',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSearchTag('Saree'),
                        _buildSearchTag('Shoes'),
                        _buildSearchTag('Smartwatch'),
                        _buildSearchTag('iPhone'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSearchTag('T-Shirt'),
                        _buildSearchTag('Jeans'),
                        _buildSearchTag('Mobile'),
                        _buildSearchTag('Kurti'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSearchTag('OLED TV'),
                        _buildSearchTag('Laptop'),
                        _buildSearchTag('Women Top'),
                        _buildSearchTag('Headphones'),
                      ],
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

  Widget _buildSearchTag(String text) {
    return GestureDetector(
      onTap: () {
        store_class.value=text;
        Navigator.push(context, MaterialPageRoute(builder: (context)=> search_results()));
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
      ),
    );
  }

  void showSpeechDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        return StatefulBuilder(
          builder: (BuildContext context,StateSetter setState) {
            callSTT(context,setState);
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Try saying something',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AvatarGlow(
                      endRadius: 55.0,
                      glowColor: Colors.red,
                      child: FloatingActionButton(
                        onPressed: () {

                        },
                        child: Icon(Icons.mic),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      store_class.value,
                      style: TextStyle(
                        fontSize: 23,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),

                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.only(left: 10,right: 10),
                      child: Text(
                        'Try saying any product name which you want to search',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void callSTT(BuildContext context, StateSetter setState) async {
    var isListening = false;

    if (!isListening) {
      var available = await speech.initialize();
      if (available) {
        if (mounted) {
          setState(() {
            isListening = true;
          });
        }

        speech.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                store_class.value = result.recognizedWords;
              });
            }
          },
          listenFor: const Duration(seconds: 3),
        );

        Timer(const Duration(seconds: 3), () {
          if (context.mounted && !speech.isListening) {
            if (Navigator.canPop(context)) {
              if(store_class.value != 'Listening'){
                final route = MaterialPageRoute(builder: (_) => search_results());
                Future.delayed(const Duration(seconds: 0), () {
                  Navigator.pushReplacement(context, route);
                });
              }
              else{
                speech.stop();
                Navigator.pop(context);
              }
            }
          }
        });
      }
    }
  }

}
