import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'AppLocalization.dart';

class EditProfilePage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> initialData;
  final Locale? locale;
  final AppLocalization appLocalization;


  EditProfilePage({required this.token, required this.initialData,required this.appLocalization,
    this.locale});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _languageController = TextEditingController();
  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  XFile? _image;
  String? _defaultPhotoUrl;
  bool _obscureTextCurrent = true;
  bool _obscureTextNew = true;
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _userNameController.text = widget.initialData['userName'];
    _emailController.text = widget.initialData['email'];
    _selectedLanguage = widget.initialData['language'];
    _getDefaultPhotoUrl();
  }


  Future<void> _getDefaultPhotoUrl() async {
    try {
      final response = await http.get(
        Uri.parse('http://guideme.somee.com/api/Tourist/default_photo'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _defaultPhotoUrl = responseData['defaultPhotoUrl'];
        });
      } else {

      }
    } catch (e) {

    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }Future<void> _updateProfile(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final uri = Uri.parse('http://guideme.runasp.net/api/Tourist/update/${_userNameController.text}');
      final headers = {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'multipart/form-data',
      };

      try {
        var request = http.MultipartRequest('PUT', uri);
        request.headers.addAll(headers);

        request.fields['userName'] = _userNameController.text;
        request.fields['email'] = _emailController.text;
        request.fields['language'] = _selectedLanguage ?? '';
        request.fields['newPass'] = _newPasswordController.text;
        request.fields['currentPass'] = _currentPasswordController.text;

        if (_image != null) {
          final mimeType = lookupMimeType(_image!.path);
          if (mimeType != null) {
            request.files.add(await http.MultipartFile.fromPath(
              'Photo',
              _image!.path,
              contentType: MediaType.parse(mimeType),
            ));
          } else {
            print('Could not determine MIME type for the selected file.');
          }
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final responseBody = response.body;
          if (responseBody.contains('Tourist Data Updated Successfully')) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.black,
                  content: Text(
                    'Tourist Data Updated Successfully',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        widget.appLocalization.translate('Ok'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            _showCustomDialog(responseBody);
          }
        } else {
          _showCustomDialog(response.body);
        }
      } catch (e) {
        print('Error updating profile: $e');
        _showCustomDialog(widget.appLocalization.translate('FailedUpdate'));
      }
    }
  }

  void _updateSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'profileData',
      jsonEncode({
        'userName': _userNameController.text,
        'email': _emailController.text,
        'language': _languageController.text,

      }),
    );
  }

  String decodeToken(String token) {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
    print('Decoded token: $decodedToken');
    return decodedToken[
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ??
        '';
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
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                widget.appLocalization.translate('Ok'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        title: Text(
          widget.appLocalization.translate('EditProfile'),
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                        child: _image != null
                            ? ClipOval(
                          child: Image.file(File(_image!.path),
                              fit: BoxFit.cover),
                        )
                            : _defaultPhotoUrl != null
                            ? ClipOval(
                          child: Image.network(_defaultPhotoUrl!,
                              fit: BoxFit.cover),
                        )
                            : Icon(
                          Icons.person,
                          size: 120,
                          color: Colors.black,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 246, 243,
                                177),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.edit, color: Colors.black),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height:16),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                  ),
                  child: TextFormField(
                    controller: _userNameController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: widget.appLocalization.translate('UserName'),
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 13),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: widget.appLocalization.translate('Email'),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return widget.appLocalization.translate('PlaceHolder2');
                    }
                    return null;
                  },
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  items: [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: 'ar',
                      child: Text('Arabic'),
                    ),
                    DropdownMenuItem(
                      value: 'fr',
                      child: Text('French'),
                    ),
                    DropdownMenuItem(
                      value: 'it',
                      child: Text('Italian'),
                    ),
                    DropdownMenuItem(
                      value: 'es',
                      child: Text('Spanish'),
                    ),
                    DropdownMenuItem(
                      value: 'de',
                      child: Text('German'),
                    ),
                    DropdownMenuItem(
                      value: 'ru',
                      child: Text('Russian'),
                    ),
                    DropdownMenuItem(
                      value: 'zh',
                      child: Text('Chinese'),
                    ),
                    DropdownMenuItem(
                      value: 'ja',
                      child: Text('Japanese'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: widget.appLocalization.translate('Language'),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    suffixIcon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLanguage = newValue;
                    });
                  },
                  dropdownColor: Colors.black,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedItemBuilder: (BuildContext context) {
                    return [
                      'English',
                      'Arabic',
                      'French',
                      'Italian',
                      'Spanish',
                      'German',
                      'Russian',
                      'Chinese',
                      'Japanese',
                    ].map<Widget>((String item) {
                      return Text(
                        item,
                        style: TextStyle(
                          color: _selectedLanguage == item.toLowerCase()
                              ? Colors.white
                              : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(
                    labelText: widget.appLocalization.translate('CurrentPass'),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  obscureText: _obscureTextCurrent,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: widget.appLocalization.translate('NewPass'),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  obscureText: _obscureTextNew,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _updateProfile(context);
                  },
                  child: Text(
                    widget.appLocalization.translate('UpdateProfile'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 85, 147, 191),
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