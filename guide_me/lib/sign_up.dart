import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _languageController = TextEditingController();

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
    final String language = _languageController.text;

    final response = await http.post(
      Uri.parse('http://guide-me.somee.com/api/Tourist/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'language': language,
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
          builder: (context) => home_page(token: token),
        ),
      );
    } else {
      String errorMessage = 'An error occurred';
      if (response.body != null && response.body.isNotEmpty) {
        final errorResponse = jsonDecode(response.body);
        errorMessage = errorResponse['message'] ?? 'An error occurred';

        if (errorMessage == "Passwords must have at least one uppercase ('A'-'Z')") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text(errorMessage),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else if (errorMessage == "Username is already taken.") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text(errorMessage),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background_image.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Guide Me',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                      buildTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$")
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
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
                      buildTextField(
                        controller: _languageController,
                        labelText: 'Language',
                        prefixIcon: Icons.language,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your language';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _signUp(); // Call _signUp() method here
                    }
                  },
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text(
                    'Sign Up',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15.0), backgroundColor: Color.fromARGB(255, 39, 84, 105),
                    minimumSize: Size(120, 0), // Change button color here
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25), // Change border radius here
                    ),
                  ),
                ),
              ],
            ),
          ),
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

    // Create a FocusNode for the TextField
    FocusNode focusNode = FocusNode();

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
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
              icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
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
