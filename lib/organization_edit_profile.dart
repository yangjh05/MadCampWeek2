// organization_edit_profile.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:madcamp_week2/home.dart';
import 'package:madcamp_week2/organization_page.dart';

class OrganizationEditProfilePage extends StatefulWidget {
  final user_info;

  OrganizationEditProfilePage({required this.user_info});

  @override
  _OrganizationEditProfilePageState createState() =>
      _OrganizationEditProfilePageState(user_info: user_info);
}

class _OrganizationEditProfilePageState
    extends State<OrganizationEditProfilePage> {
  final user_info;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;

  _OrganizationEditProfilePageState({required this.user_info});

  @override
  void initState() {
    super.initState();
    print(user_info);
    _usernameController = TextEditingController(text: user_info['username']);
    _emailController = TextEditingController(text: user_info['email']);
    _descriptionController =
        TextEditingController(text: user_info['description']);
    _phoneController = TextEditingController(text: user_info['phone_number']);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final response =
          await http.post(Uri.parse("https://172.10.7.95/api/update_desc"),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(<String, String>{
                'user_id': user_info['user_id'].toString(),
                'name': _usernameController.text,
                'desc': _descriptionController.text,
                'email': _emailController.text,
                'phone': _phoneController.text,
              }));
      if (response.statusCode == 201)
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                user_info: jsonDecode(response.body)['user'],
                //org_info: org_info,
              ),
            ),
            (Route<dynamic> route) => route.isFirst);
      else
        throw Exception();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF495ECA),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('프로필 수정',
                  style: TextStyle(
                      fontSize: 42,
                      color: Color(0xFF495ECA),
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                '프로필은 언제든 수정할 수 있습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 30.0),
              Center(
                child: ClipOval(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/profile_icon.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Text('이름', style: TextStyle(fontSize: 16, color: Colors.black)),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8.0),
              Text('이메일', style: TextStyle(fontSize: 16, color: Colors.black)),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                ),
              ),
              SizedBox(height: 8.0),
              Text('휴대전화', style: TextStyle(fontSize: 16, color: Colors.black)),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                ),
              ),
              SizedBox(height: 8.0),
              Text('자기소개', style: TextStyle(fontSize: 16, color: Colors.black)),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('수정하기', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF495ECA),
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
