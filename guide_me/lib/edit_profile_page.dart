import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class edit_profile_page extends StatefulWidget {
  final String token;
  final Map<String, dynamic> initialData;

  edit_profile_page({required this.token, required this.initialData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<edit_profile_page> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _languageController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _currentPasswordController = TextEditingController();
  XFile? _image;
  bool _obscureTextCurrent = true;
  bool _obscureTextNew = true;

  @override
  void initState() {
    super.initState();
    _userNameController.text = widget.initialData['userName'];
    _emailController.text = widget.initialData['email'];
    _languageController.text = widget.initialData['language'];
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _languageController.dispose();
    _newPasswordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final uri = Uri.parse('http://guide-me.somee.com/api/Tourist/update/${_userNameController.text}');
      final headers = {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      };
      final body = {
        'userName': _userNameController.text,
        'email': _emailController.text,
        'language': _languageController.text,
        'newPass': _newPasswordController.text,
        'currentPass': _currentPasswordController.text,
      };

      try {
        final response = await http.put(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );

        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final jsonResponse = response.body;
          if (jsonResponse.contains('Tourist Data Updated Successfully')) {
            print('Success message found in response');
            _showCustomDialog('Profile updated successfully');

            Navigator.pop(context);
          } else {
            print('Success message not found in response');
            _showCustomDialog('Unknown response from server');
          }
        } else {
          final jsonResponse = response.body;
          _showCustomDialog(jsonResponse); // Display error message
        }
      } catch (e) {
        print('Error updating profile: $e');
        _showCustomDialog('Failed to update profile. Please try again.');
      }
    }
  }

  void _showCustomDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          content: Text(
            message,
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromARGB(255, 246, 243, 177),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Color.fromARGB(255, 246, 243, 177),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (_image != null)
                  Image.file(File(_image!.path), height: 100, width: 100),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Change Profile Photo',
                      style: TextStyle(color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(
                        255, 85, 147, 191), // Background color
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                      labelText: 'User Name',
                      labelStyle: TextStyle(color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      )),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold), // Text from API
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      )),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold), // Text from API
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _languageController,
                  decoration: InputDecoration(
                      labelText: 'Language',
                      labelStyle: TextStyle(color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      )),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold), // Text from API
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureTextNew = !_obscureTextNew;
                        });
                      },
                      child: Icon(
                        _obscureTextNew
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black, // Icon color black
                      ),
                    ),
                  ),
                  obscureText: _obscureTextNew,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold), // Text from API
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: TextStyle(color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureTextCurrent = !_obscureTextCurrent;
                        });
                      },
                      child: Icon(
                        _obscureTextCurrent
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black, // Icon color black
                      ),
                    ),
                  ),
                  obscureText: _obscureTextCurrent,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold), // Text from API
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: Text('Update Profile',
                      style: TextStyle(color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(
                        255, 85, 147, 191), // Background color
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
