import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';

class sign_in extends StatefulWidget {
  const sign_in({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<sign_in> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _is_loading = false;
  bool _is_obscure = true;

  Map<String, bool> _error_status = {
    'email': false,
    'password': false,
  };

  void _toggle_password_visibility() {
    setState(() {
      _is_obscure = !_is_obscure;
    });
  }

  Future<void> _sign_in() async {
    setState(() {
      _is_loading = true;
    });

    final String email = _emailController.text;
    final String password = _passwordController.text;

    final response = await http.post(
      Uri.parse('http://guide-me.somee.com/api/Tourist/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    setState(() {
      _is_loading = false;
    });

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => home_page(title: 'Home Page'), // Provide a title here
        ),
      );
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
                SizedBox(height: 150),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      build_text_field(
                        controller: _emailController,
                        label_text: 'Email',
                        prefix_icon: Icons.email,
                        keyboard_type: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 70),
                      build_text_field(
                        controller: _passwordController,
                        label_text: 'Password',
                        prefix_icon: Icons.lock,
                        is_password: true,
                        toggle_visibility: _toggle_password_visibility,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 100),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _sign_in();
                    }
                  },
                  child: _is_loading
                      ? CircularProgressIndicator()
                      : Text('Sign In'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15.0),
                    minimumSize: Size(120, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
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

  Widget build_text_field({
    required TextEditingController controller,
    required String label_text,
    required IconData prefix_icon,
    TextInputType keyboard_type = TextInputType.text,
    bool is_password = false,
    Function? toggle_visibility,
  }) {
    String field_hint_text = 'Enter your $label_text'; // Generate field-specific hint text

    return Focus(
      onFocusChange: (has_focus) {
        // Check if the field lost focus and is empty
        if (!has_focus && controller.text.isEmpty) {
          setState(() {
            _error_status[controller.toString()] = true;
          });
        }
      },
      child: TextField(
        controller: controller,
        keyboardType: keyboard_type,
        obscureText: is_password ? _is_obscure : false,
        onChanged: (value) {
          setState(() {
            _error_status[controller.toString()] = false;
          });
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          labelText: label_text,
          labelStyle: TextStyle(fontSize: 14),
          prefixIcon: Icon(prefix_icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          errorText: _error_status[controller.toString()] ?? false
              ? 'Please enter your $label_text'
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
          suffixIcon: is_password
              ? IconButton(
            icon: Icon(
                _is_obscure ? Icons.visibility : Icons.visibility_off),
            onPressed: toggle_visibility as void Function()?,
          )
              : null,
          hintText: field_hint_text, // Use field-specific hint text
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
