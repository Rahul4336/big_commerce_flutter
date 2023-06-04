import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class add_new_address extends StatefulWidget {
  @override
  _add_new_addressState createState() => _add_new_addressState();
}

class _add_new_addressState extends State<add_new_address> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  String? _addressType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    height: 50,
                    color: Color(0xfffff3f2),
                    child: Row(
                      children: [
                        // Add your child widgets here
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _phoneNumberController,
                                decoration: InputDecoration(
                                    labelText: 'Enter Phone number'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a phone number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _nameController,
                                decoration:
                                InputDecoration(labelText: 'Enter Name'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        Text('Choose Address Type'),
                        RadioListTile(
                          title: Text('Home'),
                          value: 'Home',
                          groupValue: _addressType,
                          onChanged: (value) {
                            setState(() {
                              _addressType = value;
                            });
                          },
                        ),
                        RadioListTile(
                          title: Text('Office'),
                          value: 'Office',
                          groupValue: _addressType,
                          onChanged: (value) {
                            setState(() {
                              _addressType = value;
                            });
                          },
                        ),
                        RadioListTile(
                          title: Text('Other'),
                          value: 'Other',
                          groupValue: _addressType,
                          onChanged: (value) {
                            setState(() {
                              _addressType = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _pincodeController,
                          decoration:
                          InputDecoration(labelText: 'Enter Pincode'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a pincode';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                              labelText: 'Enter Complete Address'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a complete address';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _cityController,
                          decoration:
                          InputDecoration(labelText: 'Enter City'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a city';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _stateController,
                          decoration:
                          InputDecoration(labelText: 'Enter State'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a state';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _landmarkController,
                          decoration:
                          InputDecoration(labelText: 'Enter Landmark'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a landmark';
                            }
                            return null;
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() == true) {
                              _submitForm();
                            }
                          },
                          child: Text('Submit'),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    String name = _nameController.text;
    String phoneNumber = _phoneNumberController.text;
    String pincode = _pincodeController.text;
    String address = _addressController.text;
    String city = _cityController.text;
    String state = _stateController.text;
    String landmark = _landmarkController.text;

    print('Name: $name');
    print('Phone number: $phoneNumber');
    print('Address Type: $_addressType');
    print('Pincode: $pincode');
    print('Complete Address: $address');
    print('City: $city');
    print('State: $state');
    print('Landmark: $landmark');

    // Perform further actions with the form data
  }
}
