// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class OrganizationFindUser extends StatefulWidget {
  final user_info, org_info, org_num;
  OrganizationFindUser(
      {required this.user_info, required this.org_info, required this.org_num});

  @override
  _OrganizationFindPeopleState createState() => _OrganizationFindPeopleState(
        user_info: user_info,
        org_info: org_info,
        org_num: org_num,
      );
}

class _OrganizationFindPeopleState extends State<OrganizationFindUser> {
  final user_info, org_info, org_num;
  bool isLoadingComplete = false;
  _OrganizationFindPeopleState(
      {required this.user_info, required this.org_info, required this.org_num});

  List<dynamic> info_list = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDatabase();
  }

  Future<void> getDatabase() async {
    final response = await http.post(
      Uri.parse("https://172.10.7.95/api/find_org_people"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'org_id': org_info['organization_id'].toString(),
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        isLoadingComplete = true;
        final list_info = jsonDecode(response.body);
        info_list = list_info['res'][0] ?? []; // null인 경우 빈 리스트로 설정
        info_list
            .removeWhere((item) => item['user_id'] == user_info['user_id']);
        print("Success");
      });
      print(info_list);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get response: ${response.body}')),
      );
      throw Exception();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: info_list.length == 0
            ? Text("다른 구성원이 아직 없습니다!")
            : ListView.builder(
                itemCount: info_list.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                        "역할 ${info_list[index].role_name} : ${info_list[index].username}"),
                  );
                },
              ),
      ),
    );
  }
}