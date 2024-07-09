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

  Future<void> applyResult(int user_id, int isAccept) async {
    dynamic res = [];
    print(user_id);
    final response = await http.post(
      Uri.parse("https://172.10.7.95/api/apply_result"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': user_id.toString(),
        'org_id': org_info['organization_id'].toString(),
        'appRes': isAccept.toString()
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        print("Success");
        res = jsonDecode(response.body);
        print(res);
      });

      if (isAccept == 0) {
        return;
      }

      // 각 역할의 사용자 목록에서 사용자의 이름만 추출
      List<Map<String, dynamic>> getSecondDropdownItems(dynamic userList) {
        print(userList);
        return userList.map<Map<String, dynamic>>((user) {
          print(user);
          return {
            'user_role_id': user['user_role_id'],
            'username': user['username']
          };
        }).toList();
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          int dropdownValue1 = res['roles'][0]['role_id'];
          int? dropdownValue2;

          print(dropdownValue1);

          // 첫 번째 역할의 사용자 목록에서 사용자 이름만 추출

          List<Map<String, dynamic>> secondDropdownItems =
              getSecondDropdownItems(res['userList'][0]['users']);

          return AlertDialog(
            title: Text('직급을 선택하세요'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<int>(
                      value: dropdownValue1,
                      onChanged: (int? newValue) {
                        setState(() {
                          print("new Value");
                          print(newValue);

                          dropdownValue1 = newValue!;
                          dropdownValue2 = null;

                          print("Yay");

                          // 새로운 역할에 따라 두 번째 드롭다운 항목 업데이트
                          secondDropdownItems = getSecondDropdownItems(
                            res['userList'].firstWhere((element) {
                              print(element);
                              return element['role_id'] == newValue;
                            })['users'],
                          );
                        });
                      },
                      items: res['roles'].map<DropdownMenuItem<int>>((value) {
                        return DropdownMenuItem<int>(
                          value: value['role_id'],
                          child: Text(value['role_name']),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    DropdownButton<int>(
                      value: dropdownValue2,
                      hint: Text('직속 상사를 선택하세요'),
                      onChanged: (int? newValue) {
                        setState(() {
                          dropdownValue2 = newValue!;
                          print(dropdownValue2);
                        });
                        print('Selected user_role_id: $dropdownValue2');
                      },
                      items: secondDropdownItems
                          .map<DropdownMenuItem<int>>((value) {
                        return DropdownMenuItem<int>(
                          value: value['user_role_id'],
                          child: Text(value['username']),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
            actions: <Widget>[
              TextButton(
                child: Text('확인'),
                onPressed: () async {
                  print("Ok pressed");
                  print(dropdownValue2);
                  if (dropdownValue2 == null) return;
                  Navigator.of(context).pop();
                  final finalres = await http.post(
                    Uri.parse("https://172.10.7.95/api/apply_user_org"),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, String>{
                      'org_role_id': dropdownValue1.toString(),
                      'user_id': user_id.toString(),
                      'par_user_role': dropdownValue2
                          .toString(), // 두 번째 드롭다운에서 선택된 user_role_id 값을 전달
                    }),
                  );
                  print(finalres.body);
                  setState(() {
                    info_list.removeWhere((item) => item['user_id'] == user_id);
                  });
                },
              ),
            ],
          );
        },
      );
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
                                              print(
                                                  "Member user id : ${member['user_id']}");
                                              applyResult(member['user_id'], 2);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: Size(30,
                                                  30), // 너비와 높이를 설정하여 버튼 크기 조정
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      8), // 버튼 내용의 패딩 설정
                                            ),
                                            child: Icon(Icons.account_circle),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              applyResult(member['user_id'], 1);
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
                                              applyResult(member['user_id'], 0);
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
