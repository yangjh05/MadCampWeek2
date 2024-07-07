// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:madcamp_week2/add_organization_page.dart';

class OrganizationMyPage extends StatefulWidget {
  final user_info, org_info;
  OrganizationMyPage({required this.user_info, required this.org_info});

  @override
  _OrganizationMyPageState createState() =>
      _OrganizationMyPageState(user_info: user_info, org_info: org_info);
}

class _OrganizationMyPageState extends State<OrganizationMyPage> {
  final user_info, org_info;
  _OrganizationMyPageState({required this.user_info, required this.org_info});
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
      floatingActionButton: org_info['user_state'] == 2
          ? SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              backgroundColor: Colors.blue,
              icon: Icons.settings,
              childMarginBottom: 20,
              childMarginTop: 20,
              children: [
                SpeedDialChild(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      child: Icon(Icons.manage_accounts, size: 20.0),
                    ),
                  ),
                  label: '회원 관리',
                  onTap: () => print('Add Tapped'),
                ),
                SpeedDialChild(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        child: Icon(Icons.edit, size: 20.0),
                      ),
                    ),
                    label: '단체 정보 수정',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddOrganizationPage(
                                  user_info: user_info, org_info: org_info)));
                    })
              ],
            )
          : null,
    );
  }
}
