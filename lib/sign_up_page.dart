import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController(); // 추가된 비밀번호 재입력 컨트롤러
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _passwordVisible = false;
  bool _rePasswordVisible = false;

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      String userid = _usernameController.text;
      String password = _passwordController.text;
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
          'userid': userid,
          'password': password,
          'name': name,
          'desc': bio,
          'email': email,
          'phone': phone,
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

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: Colors.grey,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: Color(0xFF495ECA),
        ),
      ),
      labelStyle: TextStyle(fontSize: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Text('Sign up',
                    style: TextStyle(
                        fontSize: 42,
                        color: Color(0xFF495ECA),
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Please create a new account',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 24),
                TextFormField(
                  controller: _usernameController,
                  decoration: _inputDecoration('ID'),
                  style: TextStyle(fontSize: 14),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your user ID';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: Color(0xFF495ECA),
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    labelStyle: TextStyle(fontSize: 14),
                  ),
                  obscureText: !_passwordVisible,
                  style: TextStyle(fontSize: 14),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                TextFormField(
                  controller: _rePasswordController,
                  decoration: InputDecoration(
                    labelText: 'Password 확인',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: Color(0xFF495ECA),
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _rePasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _rePasswordVisible = !_rePasswordVisible;
                        });
                      },
                    ),
                    labelStyle: TextStyle(fontSize: 14),
                  ),
                  obscureText: !_rePasswordVisible,
                  style: TextStyle(fontSize: 14),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please re-enter your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('이름'),
                  style: TextStyle(fontSize: 14),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                TextFormField(
                  controller: _bioController,
                  decoration: _inputDecoration('Bio (Optional)'),
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration('Email (Optional)'),
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 24),
                TextFormField(
                  controller: _phoneController,
                  decoration: _inputDecoration('Phone (Optional)'),
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _signup,
                  child: Text('Sign up',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF495ECA),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
}
