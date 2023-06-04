import 'package:big_commerce/register_bottom_sheet.dart';
import 'package:big_commerce/store_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class categories_page extends StatefulWidget{
  @override
  State<categories_page> createState() => _categories_pageState();
}

class _categories_pageState extends State<categories_page> {
  List<dynamic> data = [];
  List<dynamic> category = [];
  SharedPreferences? sharedPrefs;
  int selectedIndex = 0;
  @override
  void initState() {
    fetchMainCategory();
    super.initState();
  }

  Future<void> fetchMainCategory() async {
    sharedPrefs = await SharedPreferences.getInstance();
    final headers = {
      "dtoken": sharedPrefs?.getString("dtoken") ?? "",
    };

    final response = await http.get(
      Uri.parse('${store_class.base_url}maincategory'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        data = responseData['Data'];
      });
    }
    else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> fetchCategory(String mcid) async {
    sharedPrefs = await SharedPreferences.getInstance();
    final headers = {
      "dtoken": sharedPrefs?.getString("dtoken") ?? "",
    };

    final response = await http.get(
      Uri.parse("${store_class.base_url}category/$mcid"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      category = jsonData['Data'];
      setState(() {});
    } else {
      print('Failed to fetch data. Status code: ${response.statusCode}');
    }
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
              child: Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.all(10),
                          icon: Image.asset(
                            'assets/search.png', // Replace with your image path
                            width: 18,
                            height: 18,
                          ),
                          onPressed: () {

                            // Add your search functionality here
                          },
                        ),
                        IconButton(
                          padding: EdgeInsets.all(10),
                          icon: Image.asset(
                            'assets/heart.png', // Replace with your image path
                            width: 18,
                            height: 18,
                          ),
                          onPressed: () {
                            // Add your favorite functionality here
                          },
                        ),
                        IconButton(
                          padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                          icon: Image.asset(
                            'assets/shoppingcart.png', // Replace with your image path
                            width: 18,
                            height: 18,
                          ),
                          onPressed: () {
                            // Add your shopping cart functionality here
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: 2,
            ),

            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Color(0xFFEFEFEF),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final item = data[index];
                            final name = item['name'];
                            final mcid = item['mcid'];
                            final iconname = item['iconname'];

                            // Customize how you want to display the list item

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;// Set the selected index
                                  fetchCategory(mcid);
                                });
                              },
                              child: Container(
                                height: selectedIndex == index ? 80 : 80, // Change height based on selection
                                color: selectedIndex == index ? Colors.white : Color(0xFFEFEFEF), // Change background color based on selection
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: selectedIndex == index ? Colors.red : Colors.transparent, // Change background color based on selection
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                        ),
                                      ),
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center, // Center items vertically
                                        crossAxisAlignment: CrossAxisAlignment.center, // Center items horizontally
                                        children: [
                                          Image.network(
                                            '${store_class.base_url}static/mcat/$iconname',
                                            height: 20,
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: selectedIndex == index ? Colors.red : Colors.black, // Change font color based on selection
                                              ),
                                              textAlign: TextAlign.center, // Center the text vertically
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: Colors.white,
                      child: ListView.builder(
                        itemCount: category.length,
                        itemBuilder: (context, index) {
                          final item = category[index];
                          final name = item['name'];
                          final subcategories = item['subcategories'];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 15),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
                                    children: <Widget>[
                                      for (int i = 0; i < subcategories.length; i += 3)
                                        Row(
                                          children: [
                                            for (var subcategory in subcategories.skip(i).take(3))
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                                child: Container(
                                                  width: 70,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
                                                    children: [
                                                      ClipOval(
                                                        child: Image.network(
                                                          '${store_class.base_url}/static/subcat/${subcategory['iconname']}',
                                                          height: 50,
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Padding(
                                                        padding: EdgeInsets.only(bottom: 5),
                                                        child: Text(
                                                          subcategory['name'],
                                                          style: TextStyle(fontSize: 11),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            SizedBox(width: 10), // Add spacing between columns
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
                    ),
                  ),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



}