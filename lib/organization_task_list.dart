import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:madcamp_week2/add_task_page.dart';

class OrganizationTaskList extends StatefulWidget {
  final user_info, org_info;
  OrganizationTaskList({required this.user_info, required this.org_info});

  @override
  _OrganizationTaskListState createState() =>
      _OrganizationTaskListState(user_info: user_info, org_info: org_info);
}

class _OrganizationTaskListState extends State<OrganizationTaskList> {
  final user_info, org_info;
  int cnt = 0;
  List<dynamic> taskList = [];
  bool _isLoadingComplete = false;

  _OrganizationTaskListState({required this.user_info, required this.org_info});

  @override
  void initState() {
    super.initState();
    getTasks();
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
        taskList = jsonDecode(response.body)['tasks'];
        _isLoadingComplete = true;
      });
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoadingComplete
        ? Scaffold(
            backgroundColor: Color(0xFFF5F5F5),
            appBar: AppBar(
              backgroundColor: Color(0xFF495ECA),
              automaticallyImplyLeading: false,
              title: Text('업무 리스트'),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
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
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 80.0), // 검색바 공간 확보
                  child: Column(
                    children: [
                      SizedBox(height: 25.0),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: taskList.length,
                          itemBuilder: (context, index) {
                            return TaskCard(
                              title: taskList[index]['title'],
                              description: taskList[index]['description'],
                              isFirst: index == 0,
                              isLast: index == taskList.length - 1,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: '검색',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return AddTaskPage(
                                    user_info: user_info,
                                    org_info: org_info,
                                  );
                                },
                              ),
                            );
                            setState(() async {
                              _isLoadingComplete = false;
                              await getTasks();
                            });
                          },
                          child: Icon(
                            Icons.post_add,
                            color: Colors.white,
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(12.0),
                            backgroundColor: Color(0xFF495ECA), // 버튼 배경색
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        : Center(child: CircularProgressIndicator());
    ;
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isFirst;
  final bool isLast;

  TaskCard({
    required this.title,
    required this.description,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 간격을 좁게 설정
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isFirst ? 16.0 : 0),
            topRight: Radius.circular(isFirst ? 16.0 : 0),
            bottomLeft: Radius.circular(isLast ? 16.0 : 0),
            bottomRight: Radius.circular(isLast ? 16.0 : 0),
          ),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(Icons.calendar_today, color: Colors.black),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(description),
        ),
      ),
    );
  }
}
