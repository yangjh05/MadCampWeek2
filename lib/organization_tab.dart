import 'package:flutter/material.dart';
import 'organization_find_people.dart';
import 'organization_home.dart';
import 'organization_task_list.dart';

class OrganizationNavigator extends StatefulWidget {
  final user_info, org_info, org_num;
  OrganizationNavigator(
      {required this.user_info, required this.org_info, required this.org_num});

  @override
  _OrganizationNavigatorState createState() => _OrganizationNavigatorState(
        user_info: user_info,
        org_info: org_info,
        org_num: org_num,
      );
}

class _OrganizationNavigatorState extends State<OrganizationNavigator> {
  int _selectedIndex = 1;
  final user_info, org_info, org_num;
  _OrganizationNavigatorState(
      {required this.user_info, required this.org_info, required this.org_num});

  List<Widget> _widgetOptions() => <Widget>[
        OrganizationTaskList(
          user_info: user_info,
          org_info: org_info,
        ),
        OrganizationHome(
          user_info: user_info,
          org_info: org_info,
          org_num: org_num,
        ),
        OrganizationFindUser(
          user_info: user_info,
          org_info: org_info,
          org_num: org_num,
        ),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) =>
            _widgetOptions().elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Task List',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedIndex == 1
                    ? Color(0xFF495ECA)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home,
                color: _selectedIndex == 1 ? Colors.white : Colors.grey,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.find_in_page),
            label: 'Find People',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF495ECA),
        backgroundColor: Colors.white, // BottomNavigationBar 배경색 변경
        onTap: _onItemTapped,
      ),
    );
  }
}
