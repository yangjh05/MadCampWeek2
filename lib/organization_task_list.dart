import 'package:flutter/material.dart';

class OrganizationTaskList extends StatefulWidget {
  final user_info, org_info;
  OrganizationTaskList({required this.user_info, required this.org_info});

  @override
  _OrganizationTaskListState createState() =>
      _OrganizationTaskListState(user_info: user_info, org_info: org_info);
}

class _OrganizationTaskListState extends State<OrganizationTaskList> {
  final user_info, org_info;
  _OrganizationTaskListState({required this.user_info, required this.org_info});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF495ECA),
        automaticallyImplyLeading: false,
        title: Text('업무 리스트'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80.0), // 검색바 공간 확보
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                TaskCard(
                  title: '2024S 일정',
                  description: '2024S DB에 속함',
                ),
                TaskCard(
                  title: '2024S DB',
                  description: '공지사항에 속함',
                ),
                TaskCard(
                  title: '공통과제 / 스크럼',
                  description: '공지사항에 속함',
                ),
                TaskCard(
                  title: '빠른 메모',
                  description: '개인 메모지',
                ),
                TaskCard(
                  title: '공지사항',
                  description: '2024S DB에 속함',
                ),
                TaskCard(
                  title: '스크럼 회의록',
                  description: '2024S 스크럼 회의록에 속함',
                ),
                TaskCard(
                  title: '2반반',
                  description: '2024S 분반에 속함',
                ),
                TaskCard(
                  title: 'KCLOUD VM / 모바일 VPN 계정',
                  description: '공지사항에 속함',
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
              color: Colors.white, // 검색바 배경색
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
                    onPressed: () {
                      // 작성 버튼 눌렀을 때의 동작
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
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String description;

  TaskCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: Colors.black),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
      ),
    );
  }
}
