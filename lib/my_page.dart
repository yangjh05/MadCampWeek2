// organization_my_page.dart
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'organization_edit_profile.dart';

class MyPageTab extends StatefulWidget {
  final user_info;
  MyPageTab({required this.user_info});

  @override
  _OrganizationMyPageState createState() =>
      _OrganizationMyPageState(user_info: user_info);
}

class _OrganizationMyPageState extends State<MyPageTab> {
  final user_info;
  _OrganizationMyPageState({required this.user_info});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF495ECA),
        automaticallyImplyLeading: false,
        title: Text('마이페이지'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            children: [
              // Text(
              //   org_info['org_name'],
              //   style: TextStyle(
              //     fontSize: 24,
              //     fontFamily: 'PlusJakartSans',
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              SizedBox(height: 16.0),
              CircleAvatar(
                radius: 70, // 이미지의 크기를 설정합니다.
                backgroundImage:
                    AssetImage('assets/profile_icon.png'), // 이미지 경로를 설정합니다.
              ),
              SizedBox(height: 8.0),
              Text(
                user_info['username'],
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'PlusJakartSans',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                user_info['email'],
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'PlusJakartSans',
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                "Tel: ${user_info['phone_number']}",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'PlusJakartSans',
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                width: 350, // 고정된 너비
                height: 150, // 고정된 높이
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: SingleChildScrollView(
                  // 내용이 넘칠 경우 스크롤 가능하게 설정
                  child: Text(
                    user_info['description'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrganizationEditProfilePage(
                        user_info: user_info,
                        //org_info: org_info,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.edit, color: Colors.white),
                label: Text(
                  "프로필 수정",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF495ECA),
                  minimumSize: Size(double.infinity, 48),
                  side: BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }
}
