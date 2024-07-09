// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class AcceptApplication extends StatefulWidget {
  final user_info, org_info, org_num;
  AcceptApplication(
      {required this.user_info, required this.org_info, required this.org_num});

  @override
  _AcceptApplicationState createState() => _AcceptApplicationState(
        user_info: user_info,
        org_info: org_info,
        org_num: org_num,
      );
}

class _AcceptApplicationState extends State<AcceptApplication> {
  final user_info, org_info, org_num;
  bool isLoadingComplete = false;
  _AcceptApplicationState(
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
      Uri.parse("https://172.10.7.95/api/accept_waiting_people"),
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFF495ECA),
          automaticallyImplyLeading: false,
          title: Text('가입 신청 회원'),
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
        body: Scaffold(
          body: isLoadingComplete
              ? Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '전체 ${info_list.length}명', // 전체 구성원 수
                        style: TextStyle(fontSize: 16),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: info_list.length,
                          itemBuilder: (context, index) {
                            var member = info_list[index];
                            return Column(
                              children: [
                                ListTile(
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundImage: AssetImage(
                                          'assets/profile_icon.png'), // 기본 이미지 경로 설정
                                    ),
                                    title: Text(member['username']),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(member['email']),
                                      ],
                                    ),
                                    trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              // 버튼을 눌렀을 때 실행될 코드 작성
                                            },
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: Size(30,
                                                  30), // 너비와 높이를 설정하여 버튼 크기 조정
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      8), // 버튼 내용의 패딩 설정
                                            ),
                                            child: Icon(Icons.circle_outlined),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              // 버튼을 눌렀을 때 실행될 코드 작성
                                            },
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: Size(30,
                                                  30), // 너비와 높이를 설정하여 버튼 크기 조정
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      8), // 버튼 내용의 패딩 설정
                                            ),
                                            child: Icon(Icons.close),
                                          ),
                                        ])),
                                Divider(),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : Center(child: CircularProgressIndicator()),
        ));
  }
}
