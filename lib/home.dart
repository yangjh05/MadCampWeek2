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

  final DraggableScrollableController _draggableScrollableController =
      DraggableScrollableController();

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

  void _expandDraggableScrollableSheet() {
    _draggableScrollableController.animateTo(
      0.9, // 원하는 크기로 설정
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _collapseDraggableScrollableSheet() {
    _draggableScrollableController.animateTo(
      0.11, // 초기 크기로 설정
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(193.0), // AppBar의 높이를 설정
        child: AppBar(
          automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
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
                    Text(
                      "Organizations",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Welcome, ${user_info['username']!}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          _widgetOptions().elementAt(_selectedIndex),
          DraggableScrollableSheet(
            controller: _draggableScrollableController,
            initialChildSize: 0.11,
            minChildSize: 0.11,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, -1),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_draggableScrollableController.size == 0.11) {
                          _expandDraggableScrollableSheet();
                        } else {
                          _collapseDraggableScrollableSheet();
                        }
                      },
                      onVerticalDragUpdate: (details) {
                        scrollController.jumpTo(
                          scrollController.position.pixels -
                              details.primaryDelta!,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF495ECA),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '조직 찾기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Scrollbar(
                        thickness: 6.0,
                        radius: Radius.circular(10),
                        controller: scrollController,
                        child: ListView(
                          controller: scrollController,
                          padding: EdgeInsets.all(8.0),
                          children: [
                            ListTile(
                              leading: Icon(Icons.search),
                              title: Text('찾고 싶은 조직을 검색하세요'),
                            ),
                            // 추가적인 콘텐츠 추가
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
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
            icon: Icon(Icons.settings),
            label: 'Settings',
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
