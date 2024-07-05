import 'package:flutter/material.dart';
import 'organization_page.dart';
import 'my_page.dart';
import 'setting_page.dart';

class HomeScreen extends StatefulWidget {
  final user_info;
  HomeScreen({required this.user_info});

  @override
  _HomeScreenState createState() => _HomeScreenState(user_info: user_info);
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  final user_info;
  _HomeScreenState({required this.user_info});

  List<Widget> _widgetOptions() => <Widget>[
        MyPageTab(
          user_info: user_info,
        ),
        OrganizationTab(
          user_info: user_info,
        ),
        SettingsTab(
          user_info: user_info,
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
      appBar: AppBar(
        title: Text("Welcome, ${user_info['username']}!"),
      ),
      body: _widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Page',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedIndex == 1 ? Colors.blue : Colors.transparent,
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
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
