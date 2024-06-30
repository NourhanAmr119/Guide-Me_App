import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isObscure = true;

  Map<String, bool> _errorStatus = {
    'username': false,
    'password': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        position: DecorationPosition.background,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background_image.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              padding: const EdgeInsets.all(20.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Guide Me',
                      style: GoogleFonts.shrikhand(
                        textStyle: TextStyle(
                          fontSize: 43,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 229, 233, 154),
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 130),
                    buildTextField(
                      controller: _usernameController,
                      labelText: 'Username',
                      prefixIcon: Icons.account_circle,
                      errorText: _errorStatus['username'] ?? false
                          ? 'Please enter your username'
                          : null,
                      onChanged: (_) => _formKey.currentState!.validate(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() {
                            _errorStatus['username'] = true;
                          });
                          return 'Please enter your username';
                        }
                        setState(() {
                          _errorStatus['username'] = false;
                        });
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    buildTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      prefixIcon: Icons.lock,
                      isObscure: _isObscure,
                      errorText: _errorStatus['password'] ?? false
                          ? 'Please enter your password'
                          : null,
                      onChanged: (_) => _formKey.currentState!.validate(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() {
                            _errorStatus['password'] = true;
                          });
                          return 'Please enter your password';
                        }
                        setState(() {
                          _errorStatus['password'] = false;
                        });
                        return null;
                      },
                    ),
                    SizedBox(height: 70),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _signIn();
                        }
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Color.fromARGB(255, 229, 233, 154),
                          fontSize: 18,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
                        backgroundColor: Color.fromARGB(255, 35, 110, 172),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/sign_up');
                      },
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      final response = await http.post(
        Uri.parse('http://guide-me.somee.com/api/Tourist/signin'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => home_page(token: token)),
        );
      } else {
        _showErrorDialog(context, 'Invalid username or password.');
      }
    } catch (e) {
      _showErrorDialog(
        context,
        'An error occurred. Please check your internet connection and try again.',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(
            message,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
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
    required bool Function(dynamic _) onChanged,
    String? errorText,
  }) {
    String fieldHintText = 'Enter your $labelText';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword ? isObscure : false,
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
            icon: Icon(
              isObscure ? Icons.visibility : Icons.visibility_off,
              color: Colors.white, // Set icon color here
            ),
            onPressed: () {
              setState(() {
                isObscure = !isObscure; // Toggle password visibility
              });
            },
          )
              : null,
          hintText: fieldHintText,
          hintStyle: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}