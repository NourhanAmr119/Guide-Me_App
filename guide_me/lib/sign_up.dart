import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _selectedLanguage;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isObscure = true;

  Map<String, bool> _errorStatus = {
    'username': false,
    'email': false,
    'password': false,
    'confirmPassword': false,
    'language': false,
  };

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  void _updateErrorStatus(String field, bool isValid) {
    setState(() {
      _errorStatus[field] = isValid;
    });
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    final String username = _usernameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;
    final String? language = _selectedLanguage;

    try {
      final response = await http.post(
        Uri.parse('http://guideme.runasp.net/api/Tourist/signup'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'language': language!,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token']; // Get the token from response

        // Navigate to HomePage with the token
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(token: token),
          ),
        );
      } else {
        String errorMessage = 'An error occurred';
        if (response.body.isNotEmpty) {
          final errorResponse = jsonDecode(response.body);
          errorMessage = errorResponse['message'] ?? 'An error occurred';

          // Check if the error message indicates that the username already exists
          if (errorResponse['message'] != null && errorResponse['message'].contains('username already exists')) {
            errorMessage = 'The username already exists. Please choose a different username.';
          }
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(errorMessage),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white, // Set text color to white
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
              // backgroundColor: Color.fromARGB(255, 21, 82, 113),
            );
          },
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('username already exists'),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white, // Set text color to white
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
            // backgroundColor: Color.fromARGB(255, 21, 82, 113),
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background_image.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            SizedBox(height: 60.0),
            Text(
              'Guide Me',
              textAlign: TextAlign.center,
              style: GoogleFonts.shrikhand(
                textStyle: TextStyle(
                  fontSize: 43,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 229, 233, 154),
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 50.0),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  buildTextField(
                    controller: _usernameController,
                    labelText: 'Username',
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30.0),
                  buildTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$").hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30.0),
                  buildTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    prefixIcon: Icons.lock,
                    isPassword: true,
                    toggleVisibility: _togglePasswordVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 8) {
                        return 'Password should be at least 8 characters';
                      }
                      if (!value.contains(RegExp(r'[a-zA-Z]'))) {
                        return 'Password must contain at least one letter';
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'Password must contain at least one digit';
                      }
                      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                        return 'Password must contain at least one special character';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30.0),
                  buildTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    prefixIcon: Icons.lock,
                    isPassword: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30.0),
                  DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    items: [
                      DropdownMenuItem(
                        value: 'en',
                        child: Column(
                          children: [
                            Text('English'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'ar',
                        child: Column(
                          children: [
                            Text('Arabic'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'fr',
                        child: Column(
                          children: [
                            Text('French'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'it',
                        child: Column(
                          children: [
                            Text('Italy'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'es',
                        child: Column(
                          children: [
                            Text('Spanish'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'de',
                        child: Column(
                          children: [
                            Text('German'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'ru',
                        child: Column(
                          children: [
                            Text('Russian'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'zh',
                        child: Column(
                          children: [
                            Text('Chinese'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'ja',
                        child: Column(
                          children: [
                            Text('Japanese'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLanguage = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Language',
                      prefixIcon: Icon(Icons.language),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    dropdownColor: Color.fromARGB(255, 21, 82, 113),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a language';
                      }
                      return null;
                    },
                    style: TextStyle(color: Colors.white), // Set text color for dropdown items
                  ),
                  SizedBox(height: 30.0),
                  Center(
                    child: SizedBox(
                      width: 150, // Set the width to your desired value
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _signUp(); // Call _signUp() method here
                          }
                        },
                        child: _isLoading
                            ? CircularProgressIndicator()
                            : Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Color.fromARGB(255, 229, 233, 154),
                            fontSize: 18,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          backgroundColor: Color.fromARGB(255, 35, 110, 172),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/sign_in');
                    },
                    child: Center(
                      child: Text(
                        'Already have an Account? Sign in',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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

  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    Function? toggleVisibility,
    bool isObscure = true,
    String? Function(String?)? validator,
    String hintText = 'Required',
  }) {
    String fieldHintText = 'Enter your $labelText'; // Generate field-specific hint text

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          // Check if the field lost focus and is empty
          if (!hasFocus && controller.text.isEmpty) {
            setState(() {
              _errorStatus[controller.toString()] = true;
            });
          }
        },
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword ? _isObscure : false,
          onChanged: (value) {
            setState(() {
              _errorStatus[controller.toString()] = validator!(value) != null;
            });
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            labelText: labelText,
            labelStyle: TextStyle(fontSize: 14),
            prefixIcon: Icon(prefixIcon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            errorText: _errorStatus[controller.toString()] ?? false
                ? validator!(controller.text)
                : null,
            errorStyle: TextStyle(color: Colors.red),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(25.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(25.0),
            ),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
              onPressed: toggleVisibility as void Function()?,
            )
                : null,
            hintText: fieldHintText, // Use field-specific hint text
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}