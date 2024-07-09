import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:gantt_view/gantt_view.dart';
import 'package:madcamp_week2/accept_application.dart';
import 'package:madcamp_week2/add_notice_page.dart';
import 'package:madcamp_week2/add_organization_page.dart';
import 'package:madcamp_week2/organization_tab.dart';
import 'organization_find_people.dart';
import 'organization_my_page.dart';

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
      final uo_info = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get response: ${response.body}')),
      );
      throw Exception();
    }
  }

  void navigateToOrganization(int orgIndex) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrganizationNavigator(
          user_info: user_info,
          org_info: organization_list[orgIndex],
          org_num: orgIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ExampleEventItem> _items =
        Data.dummyData; // Replace with actual data

    return !role_info.isNotEmpty
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(
                  MediaQuery.of(context).size.height *
                      appbarHeight), // AppBar의 높이를 설정
              child: AppBar(
                automaticallyImplyLeading: true,
                leading: IconButton(
                  icon: Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
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
                          SizedBox(height: 8),
                          if (organization_list.isNotEmpty)
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                dropdownColor: Color(0xFF495ECA),
                                value: dropDownValue,
                                items: organization_list
                                    .map<DropdownMenuItem<String>>(
                                        (dynamic value) {
                                  return DropdownMenuItem<String>(
                                    value: value['org_name'],
                                    child: Text(
                                      value['org_name'],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropDownValue = newValue!;
                                    int newOrgIndex =
                                        organization_list.indexWhere((org) =>
                                            org['org_name'] == newValue);
                                    if (newOrgIndex != -1) {
                                      navigateToOrganization(newOrgIndex);
                                    }
                                  });
                                },
                                iconEnabledColor: Colors.white,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18 *
                                        (1 - 0.5 * (0.30 - appbarHeight) / 0.3),
                                    fontFamily: 'PlusJakartSans'),
                              ),
                            )
                          else
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
                          CircleAvatar(
                            radius: 50, // 이미지의 크기를 설정합니다.
                            backgroundImage: AssetImage(
                                'assets/profile_icon.png'), // 이미지 경로를 설정합니다.
                          ),
                          SizedBox(height: 8),
                          Text(
                            "${user_info['username']}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  18 * (1 - 0.5 * (0.3 - appbarHeight) / 0.3),
                              fontFamily: 'PlusJakartSans',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("${role_info[0]['role_name']}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15 *
                                      (1 - 0.5 * (0.3 - appbarHeight) / 0.3),
                                  fontFamily: 'PlusJakartSans')),
                          SizedBox(height: 8),
                          if (org_info['user_state'] == 2)
                            Text(
                              "관리자",
                              style: TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 15 *
                                      (1 - 0.5 * (0.3 - appbarHeight) / 0.3),
                                  fontFamily: 'PlusJakartSans',
                                  fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_none, // bell 아이콘
                          size: 24.0,
                          color: Colors.black,
                        ),
                        SizedBox(width: 4.0), // 텍스트와 아이콘 사이의 간격
                        Text(
                          '공지사항',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 160, // 공지사항 박스의 높이
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddNoticePage(
                                  user_info: user_info,
                                  org_info: org_info,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 200,
                            margin: EdgeInsets.only(left: 16.0),
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFF4EDF5),
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 2),
                                  blurRadius: 4.0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 40.0,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    '공지 추가',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.task_outlined, // bell 아이콘
                          size: 24.0,
                          color: Colors.black,
                        ),
                        SizedBox(width: 4.0), // 텍스트와 아이콘 사이의 간격
                        Text(
                          '현재 업무 상황',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 300, // 간트 차트 박스의 높이
                    padding: EdgeInsets.all(8.0), // 간트 차트와 테두리 간격
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 2),
                          blurRadius: 4.0,
                        ),
                      ],
                    ),
                    child: GanttChart<ExampleEventItem>(
                      rows: _items.toRows(),
                      style: GanttStyle(
                        columnWidth: 100,
                        barHeight: 30,
                        timelineAxisType: TimelineAxisType.daily,
                        tooltipType: TooltipType.hover,
                        taskBarColor: Color(0xFFE4CCFF),
                        activityLabelColor: Colors.blue.shade500,
                        taskLabelColor: Color(0xFFD1EBFF),
                        taskLabelBuilder: (task) => Container(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            task.data.title,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartSans',
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        gridColor: Colors.white,
                        taskBarRadius: 10,
                        activityLabelBuilder: (activity) {
                          return Container(
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.label!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'A subtitle',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        axisDividerColor: Colors.white,
                        tooltipColor: Color(0xFF495ECA),
                        tooltipPadding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        weekendColor: Color(0xFFF4EDF5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: org_info['user_state'] == 2
                ? SpeedDial(
                    animatedIcon: AnimatedIcons.menu_close,
                    backgroundColor: Color(0xfff9e2af),
                    icon: Icons.settings,
                    spaceBetweenChildren: 15.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)),
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
                        label: '가입 신청 회원 관리',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AcceptApplication(
                                        user_info: user_info,
                                        org_info: org_info,
                                        org_num: org_num,
                                      )));
                        },
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
                                        user_info: user_info,
                                        org_info: org_info)));
                          }),
                      SpeedDialChild(
                        child: Icon(
                          Icons.delete_outline,
                          size: 20.0,
                          color: Colors.white, // 아이콘 색상
                        ),
                        backgroundColor:
                            Color.fromARGB(255, 243, 61, 33), // 버튼 배경색
                        foregroundColor: Colors.white, // 텍스트 색상
                        label: '단체 탈퇴하기',
                        onTap: () {},
                      )
                    ],
                  )
                : null,
          );
  }
}

class NoticeCard extends StatelessWidget {
  final String title;
  final String content;

  NoticeCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      margin: EdgeInsets.only(left: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Expanded(
            child: Text(
              content,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// 데이터 모델 예제입니다. 실제 데이터에 맞게 수정해주세요.
class ExampleEventItem {
  final String title;
  final DateTime start;
  final DateTime end;
  final String group;

  ExampleEventItem({
    required this.title,
    required this.start,
    required this.end,
    required this.group,
  });
}

class Data {
  static List<ExampleEventItem> dummyData = [
    ExampleEventItem(
      title: 'Task 1',
      start: DateTime(2022, 6, 7),
      end: DateTime(2022, 6, 10),
      group: 'Group 1',
    ),
    ExampleEventItem(
      title: 'Task 2',
      start: DateTime(2022, 6, 11),
      end: DateTime(2022, 6, 13),
      group: 'Group 1',
    ),
    ExampleEventItem(
      title: 'Task 3',
      start: DateTime(2022, 6, 14),
      end: DateTime(2022, 6, 18),
      group: 'Group 2',
    ),
  ];
}

extension on DateTime {
  String get formattedDate => '$year/$month/$day';
}

extension on List<ExampleEventItem> {
  List<GridRow> toRows() {
    List<GridRow> rows = [];
    Map<String, List<TaskGridRow<ExampleEventItem>>> labelTasks = {};

    sort((a, b) => a.start.compareTo(b.start));

    for (var item in this) {
      final label = item.group;
      (labelTasks[label] ??= []).add(TaskGridRow<ExampleEventItem>(
        data: item,
        startDate: item.start,
        endDate: item.end,
        tooltip:
            '${item.title}\n${item.start.formattedDate} - ${item.end.formattedDate}',
      ));
    }

    for (var label in labelTasks.keys) {
      rows.add(ActivityGridRow(label));
      rows.addAll(labelTasks[label]!);
    }

    return rows;
  }
}
