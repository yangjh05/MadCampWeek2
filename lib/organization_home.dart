import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:gantt_view/gantt_view.dart';
import 'package:madcamp_week2/accept_application.dart';
import 'package:madcamp_week2/add_notice_page.dart';
import 'package:madcamp_week2/add_organization_page.dart';
import 'package:madcamp_week2/home.dart';
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
  List<dynamic> notices = [];
  List<EventItem> taskList = [];

  @override
  void initState() {
    super.initState();
    getMyOrganizations();
    getUserInformation();
    getNotices();
    getTasks();
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

  Future<void> getNotices() async {
    final response = await http.post(
      Uri.parse("https://172.10.7.95/api/get_notices"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'organization_id': org_info['organization_id'].toString(),
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        notices = jsonDecode(response.body)['notices'] ?? [];
      });
      print(notices);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notices')),
      );
      throw Exception('Failed to load notices');
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

  Future<void> getTasks() async {
    final response = await http.post(
      Uri.parse("https://172.10.7.95/api/get_tasks"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': user_info['user_id'].toString(),
        'organization_id': org_info['organization_id'].toString(),
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        List<dynamic> tasks = jsonDecode(response.body)['tasks'] ?? [];
        taskList = tasks
            .map((task) => EventItem(
                title: task['title'],
                start: DateTime.parse(task['start_date']),
                end: DateTime.parse(task['end_date']),
                group: 'Tasks'))
            .toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tasks')),
      );
      throw Exception('Failed to load tasks');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<EventItem> _items = taskList; // Replace with actual data

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
                    height: 160, // 공지사항 박스의 높이를 조정합니다.
                    child: ListView.builder(
                      clipBehavior: Clip.none,
                      scrollDirection: Axis.horizontal,
                      itemCount: notices.length + 1, // 공지 추가 카드를 위해 +1
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // 첫 번째에 공지 추가 카드
                          return GestureDetector(
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
                          );
                        } else {
                          final notice = notices[index - 1];
                          return NoticeCard(
                            title: notice['title'],
                            content: notice['content'],
                          );
                        }
                      },
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
                    child: taskList.isNotEmpty
                        ? GanttChart<EventItem>(
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
                              axisDividerColor: Colors.white,
                              tooltipColor: Color(0xFF495ECA),
                              tooltipPadding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              weekendColor: Color(0xFFF4EDF5),
                            ),
                          )
                        : Center(child: Text('진행 중인 업무가 없습니다.')),
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
                        onTap: () async {
                          final response = await http.post(
                              Uri.parse(
                                  "https://172.10.7.95/api/delete_subtree"),
                              headers: <String, String>{
                                'Content-Type':
                                    'application/json; charset=UTF-8',
                              },
                              body: jsonEncode(<String, String>{
                                'user_id': user_info['user_id'].toString(),
                              }));

                          if (response.statusCode == 200) {
                            setState(() {
                              print(response.body);
                            });
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to get response: ${response.body}')),
                            );
                            throw Exception();
                          }
                        },
                      )
                    ],
                  )
                : SpeedDial(
                    animatedIcon: AnimatedIcons.menu_close,
                    backgroundColor: Color(0xfff9e2af),
                    icon: Icons.settings,
                    spaceBetweenChildren: 15.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    children: [
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
                        onTap: () async {
                          if (org_info['user_state'] == 2) {
                            final managers = await http.post(
                                Uri.parse(
                                    "https://172.10.7.95/api/get_nonmanager_users"),
                                headers: <String, String>{
                                  'Content-Type':
                                      'application/json; charset=UTF-8',
                                },
                                body: jsonEncode(<String, String>{
                                  'organization_id': org_info['organization_id']
                                }));
                            final manager_list =
                                jsonDecode(managers.body)['users'];
                            if (manager_list.length == 1) {
                              final non_managers = await http.post(
                                  Uri.parse(
                                      "https://172.10.7.95/api/get_nonmanager_users"),
                                  headers: <String, String>{
                                    'Content-Type':
                                        'application/json; charset=UTF-8',
                                  },
                                  body: jsonEncode(<String, String>{
                                    'organization_id':
                                        org_info['organization_id']
                                  }));
                              final non_manager_list =
                                  jsonDecode(non_managers.body)['users'];
                              if (non_manager_list.length == 0) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('경고'),
                                      content: Text(
                                          '당신이 마지막 남은 회원입니다. 당신이 탈퇴하면 단체가 삭제됩니다. 계속하시겠습니까?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('취소'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            return;
                                          },
                                        ),
                                        TextButton(
                                          child: Text('계속'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          }
                          final response = await http.post(
                              Uri.parse(
                                  "https://172.10.7.95/api/delete_subtree"),
                              headers: <String, String>{
                                'Content-Type':
                                    'application/json; charset=UTF-8',
                              },
                              body: jsonEncode(<String, String>{
                                'user_id': user_info['user_id'].toString(),
                                'organization_id':
                                    org_info['organization_id'].toString(),
                              }));

                          if (response.statusCode == 200) {
                            setState(() {
                              print(response.body);
                            });
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) {
                                  return HomeScreen(user_info: user_info);
                                },
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to get response: ${response.body}')),
                            );
                            throw Exception();
                          }
                        },
                      )
                    ],
                  ),
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

class EventItem {
  final String title;
  final DateTime start;
  final DateTime end;
  final String group;

  EventItem({
    required this.title,
    required this.start,
    required this.end,
    required this.group,
  });
}

extension on DateTime {
  String get formattedDate => '$year/$month/$day';
}

extension on List<EventItem> {
  List<GridRow> toRows() {
    List<GridRow> rows = [];
    Map<String, List<TaskGridRow<EventItem>>> labelTasks = {};

    for (var item in this) {
      final label = item.group;
      (labelTasks[label] ??= []).add(TaskGridRow<EventItem>(
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
