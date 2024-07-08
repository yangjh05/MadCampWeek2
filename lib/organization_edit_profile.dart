// organization_edit_profile.dart
import 'package:flutter/material.dart';

class OrganizationEditProfilePage extends StatefulWidget {
  final user_info, org_info;

  OrganizationEditProfilePage(
      {required this.user_info, required this.org_info});

  @override
  _OrganizationEditProfilePageState createState() =>
      _OrganizationEditProfilePageState(
          user_info: user_info, org_info: org_info);
}

class _OrganizationEditProfilePageState
    extends State<OrganizationEditProfilePage> {
  final user_info, org_info;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _descriptionController;

  _OrganizationEditProfilePageState(
      {required this.user_info, required this.org_info});

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: user_info['username']);
    _emailController = TextEditingController(text: user_info['email']);
    _descriptionController =
        TextEditingController(text: user_info['description']);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Perform save operation, e.g., send updated data to server
      print('Profile saved');
      Navigator.of(context).pop();
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
              SizedBox(height: 16.0),
              Text('이메일', style: TextStyle(fontSize: 16, color: Colors.black)),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Text('자기소개', style: TextStyle(fontSize: 16, color: Colors.black)),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '자기소개를 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.0),
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
