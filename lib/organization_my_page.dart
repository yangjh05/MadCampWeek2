// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

class OrganizationMyPage extends StatefulWidget {
  final user_info;
  OrganizationMyPage({required this.user_info});

  @override
  _OrganizationMyPageState createState() =>
      _OrganizationMyPageState(user_info: user_info);
}

class _OrganizationMyPageState extends State<OrganizationMyPage> {
  final user_info;
  _OrganizationMyPageState({required this.user_info});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            CircleAvatar(
              radius: 50, // 이미지의 크기를 설정합니다.
              backgroundImage:
                  AssetImage('assets/profile.jpg'), // 이미지 경로를 설정합니다.
            ),
            Text("User Name: ${user_info['username']}"),
            Text("User E-mail: ${user_info['email']}"),
            Text("User description: ${user_info['description'] ?? "None"}"),
            ElevatedButton(onPressed: () {}, child: Text("프로필 수정")),
            ElevatedButton(onPressed: () {}, child: Text("조직 탈퇴")),
          ],
        ),
      ),
    );
  }
}
