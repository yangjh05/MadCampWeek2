// organization_my_page.dart
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

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
    return Scaffold();
  }
}
