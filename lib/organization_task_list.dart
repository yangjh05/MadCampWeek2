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
  List<dynamic> filteredTaskList = [];
  bool _isLoadingComplete = false;
  TextEditingController _searchController = TextEditingController();

  _OrganizationTaskListState({required this.user_info, required this.org_info});

  @override
  void initState() {
    super.initState();
    getTasks();
    _searchController.addListener(_filterTasks);
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
        filteredTaskList = taskList;
        _isLoadingComplete = true;
      });
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  void _filterTasks() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredTaskList = taskList
          .where((task) => task['title'].toLowerCase().contains(query))
          .toList();
    });
  }

  void showTaskDetails(BuildContext context, String title, String description,
      String username, String start_date, String end_date) {
    String formattedStartDate = start_date.split('T')[0];
    String formattedEndDate = end_date.split('T')[0];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('업무 담당자', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(username),
              SizedBox(height: 10),
              Text('업무 설명', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(description),
              SizedBox(height: 10),
              Text('업무 기간', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('$formattedStartDate ~ $formattedEndDate'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '닫기',
                style: TextStyle(color: Color(0xFF495ECA)),
              ),
            ),
          ],
        );
      },
    );
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
                          itemCount: filteredTaskList.length,
                          itemBuilder: (context, index) {
                            return TaskCard(
                              title: filteredTaskList[index]['title'],
                              description: filteredTaskList[index]
                                  ['description'],
                              isFirst: index == 0,
                              isLast: index == filteredTaskList.length - 1,
                              onTap: () {
                                showTaskDetails(
                                    context,
                                    filteredTaskList[index]['title'],
                                    filteredTaskList[index]['description'],
                                    filteredTaskList[index]['username'],
                                    filteredTaskList[index]['start_date'],
                                    filteredTaskList[index]['end_date']);
                              },
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
                            controller: _searchController,
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
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  TaskCard({
    required this.title,
    required this.description,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.black),
              title: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(description),
            ),
          ),
        ),
      ),
    );
  }
}
