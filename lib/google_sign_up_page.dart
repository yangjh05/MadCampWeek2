import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class GoogleSignUpScreen extends StatefulWidget {
  final username, googleId, email;
  GoogleSignUpScreen({
    required this.email,
    required this.username,
    required this.googleId,
  });

  @override
  _GoogleSignUpScreenState createState() => _GoogleSignUpScreenState(
      username: username, email: email, googleId: googleId);
}

class _GoogleSignUpScreenState extends State<GoogleSignUpScreen> {
  final username, googleId, email;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  _GoogleSignUpScreenState({
    required this.email,
    required this.username,
    required this.googleId,
  });

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String bio = _bioController.text;
      String email = _emailController.text;
      String phone = _phoneController.text;

      // 서버로 회원가입 요청을 보내고 응답을 처리합니다.
      final response = await http.post(
        Uri.parse('https://172.10.7.95/api/signup'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'userid': email,
          'password': googleId,
          'name': name,
          'desc': bio,
          'email': email,
          'phone': phone,
          'googleId': googleId,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup successful')),
        );
        Navigator.pop(context); // 회원가입 성공 시 로그인 화면으로 돌아감
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign up: ${response.body}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup with Google'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(labelText: 'Bio (optional)'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email (optional)'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone (optional)'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signup,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
