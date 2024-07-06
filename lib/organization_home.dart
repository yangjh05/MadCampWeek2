// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class OrganizationHome extends StatefulWidget {
  final user_info, org_info, org_num;
  OrganizationHome(
      {required this.user_info, required this.org_info, required this.org_num});

  @override
  _OrganizationHomeState createState() => _OrganizationHomeState(
      user_info: user_info, org_info: org_info, org_num: org_num);
}

class _OrganizationHomeState extends State<OrganizationHome> {
  final user_info, org_info, org_num;
  _OrganizationHomeState(
      {required this.user_info, required this.org_info, required this.org_num});
  double appbarHeight = 0.30;
  bool isLoadingComplete = false;
  String? dropDownValue;

  dynamic organization_list = [];
  dynamic role_info = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyOrganizations();
    getUserInformation();
    setState(() {
      isLoadingComplete = true;
    });
  }

  void getMyOrganizations() async {
    final response =
        await http.post(Uri.parse("https://172.10.7.95/api/my_organizations"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'user_id': user_info['user_id'].toString(),
            }));

    if (response.statusCode == 200) {
      setState(() {
        print(response.body);
        final org_info = jsonDecode(response.body);
        organization_list = org_info['organizations'];
        if (organization_list.isNotEmpty) {
          dropDownValue = organization_list[org_num]['org_name'];
        }
      });
      print(organization_list);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get response: ${response.body}')),
      );
      throw Exception();
    }
  }

  void getUserInformation() async {
    final response = await http.post(
        Uri.parse("https://172.10.7.95/api/user_organization_info"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'user_id': user_info['user_id'].toString(),
          'organization_id': org_info['organization_id'].toString()
        }));

    if (response.statusCode == 200) {
      setState(() {
        final uo_info = jsonDecode(response.body);
        role_info = uo_info['role'];
        print(role_info);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get response: ${response.body}')),
      );
      throw Exception();
    }
  }

  @override
  Widget build(BuildContext context) {
    return !role_info.isNotEmpty
        ? CircularProgressIndicator()
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(
                  MediaQuery.of(context).size.height *
                      appbarHeight), // AppBar의 높이를 설정
              child: AppBar(
                flexibleSpace: Stack(
                  children: [
                    Positioned.fill(
                      child: Image(
                        image: AssetImage('assets/title_background.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // organization_list.isNotEmpty
                          //     ? DropdownButton<String>(
                          //         value: dropDownValue,
                          //         items: organization_list
                          //             .map<DropdownMenuItem<String>>((dynamic value) {
                          //           return DropdownMenuItem<String>(
                          //             value: value['org_name'],
                          //             child: Text(value['org_name']),
                          //           );
                          //         }).toList(),
                          //         onChanged: (String? newValue) {
                          //           setState(() {
                          //             dropDownValue = newValue!;
                          //           });
                          //         },
                          //       )
                          //     : CircularProgressIndicator(),
                          CircleAvatar(
                            radius: 50, // 이미지의 크기를 설정합니다.
                            backgroundImage: AssetImage(
                                'assets/profile.jpg'), // 이미지 경로를 설정합니다.
                          ),
                          SizedBox(height: 8),
                          Text(
                            org_info['org_name'],
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'PlusJakartSans',
                                fontSize: 25 *
                                    (1 - 0.5 * (0.30 - appbarHeight) / 0.3),
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Welcome, ${user_info['username']}, 역할 : ${role_info[0]['role_name']}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  18 * (1 - 0.5 * (0.3 - appbarHeight) / 0.3),
                              fontFamily: 'PlusJakartSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50, // 이미지의 크기를 설정합니다.
                    backgroundImage:
                        AssetImage('assets/profile.jpg'), // 이미지 경로를 설정합니다.
                  ),
                  Text("User Name: ${user_info['username']}"),
                ],
              ),
            ),
          );
  }
}
