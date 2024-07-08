import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'organization_page.dart';
import 'my_page.dart';
import 'setting_page.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final user_info;
  HomeScreen({required this.user_info});

  @override
  _HomeScreenState createState() => _HomeScreenState(user_info: user_info);
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  final user_info;
  List<dynamic> organization_list = [];
  List<dynamic> filtered_organization_list = [];
  bool orgExists = true;
  bool isLoadingComplete = false;
  double appbarHeight = 0.21;
  late AnimationController _controller;
  late Animation<double> _animation;
  late OverlayEntry _overlayEntry;
  TextEditingController searchController = TextEditingController();
  bool _visible = false;

  _HomeScreenState({required this.user_info});

  final DraggableScrollableController _draggableScrollableController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    getOrganizationList();
    searchController.addListener(_filterList);

    _controller = AnimationController(
      duration: Duration(milliseconds: 500), // 애니메이션 지속 시간
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.21, end: 0.12).animate(_controller)
      ..addListener(() {
        setState(() {
          appbarHeight = _animation.value; // 애니메이션 값을 변수에 할당
        });
      });
  }

  void getOrganizationList() async {
    print('Getting Organization List');
    final response = await http.post(
      Uri.parse("https://172.10.7.95/api/all_organizations"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': user_info['user_id'].toString(),
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        isLoadingComplete = true;
        final org_info = jsonDecode(response.body);
        organization_list = org_info['organizations'] ?? [];
        filtered_organization_list = organization_list; // 초기값 설정
      });
      print("Organization List: $organization_list");
    } else if (response.statusCode == 201) {
      setState(() {
        organization_list = [];
        filtered_organization_list = [];
        isLoadingComplete = true;
        orgExists = false;
      });
      print("Success; No Organizations Yet");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get response: ${response.body}')),
      );
      throw Exception();
    }
  }

  Future<bool> applyParticipation(organization_id) async {
    final response = await http.post(
      Uri.parse("https://172.10.7.95/api/apply_participation_org"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': user_info['user_id'].toString(),
        'org_id': organization_id.toString(),
      }),
    );
    if (response.statusCode == 500)
      throw Exception();
    else
      return true;
  }

  void _showMessage() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry);
    setState(() {
      _visible = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      Future.delayed(Duration(milliseconds: 500), () {
        _overlayEntry.remove();
      });
      setState(() {
        _visible = false;
      });
    });
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: 100.0,
        left: MediaQuery.of(context).size.width / 2 - 100,
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: Duration(milliseconds: 500),
          child: Container(
            width: 200.0,
            padding: EdgeInsets.all(10.0),
            color: Colors.green,
            child: Center(
              child: Text(
                '참가신청 완료되었습니다!',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _filterList() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filtered_organization_list = organization_list.where((organization) {
        return organization['org_name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (!_controller.isCompleted) {
      _controller.forward();
    }
  }

  void _reverseAnimation() {
    if (_controller.isCompleted) {
      _controller.reverse();
    }
  }

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
      0.96, // 원하는 크기로 설정
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _collapseDraggableScrollableSheet() {
    _draggableScrollableController.animateTo(
      0.1, // 초기 크기로 설정
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
            appbarHeight), // AppBar의 높이를 설정
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
                          fontFamily: 'PlusJakartSans',
                          fontSize:
                              30 * (1 - 0.5 * (0.21 - appbarHeight) / 0.21),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Welcome, ${user_info['username']!}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20 * (1 - 0.5 * (0.21 - appbarHeight) / 0.21),
                        fontFamily: 'PlusJakartSans',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              _widgetOptions().elementAt(_selectedIndex),
              DraggableScrollableSheet(
                controller: _draggableScrollableController,
                initialChildSize: 0.1,
                minChildSize: 0.1,
                maxChildSize: 0.96,
                builder:
                    (BuildContext context, ScrollController scrollController) {
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
                            if (_draggableScrollableController.size == 0.1) {
                              _startAnimation();
                              _expandDraggableScrollableSheet();
                            } else {
                              _reverseAnimation();
                              _collapseDraggableScrollableSheet();
                            }
                          },
                          onVerticalDragUpdate: (details) {
                            if (details.primaryDelta! < 0) {
                              _startAnimation();
                              _expandDraggableScrollableSheet();
                            } else {
                              _reverseAnimation();
                              _collapseDraggableScrollableSheet();
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(
                                (constraints.maxHeight * 0.1 - 25) / 2),
                            decoration: BoxDecoration(
                              color: Color(0xFF495ECA),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16.0),
                                topRight: Radius.circular(16.0),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '단체 찾기',
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
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 300.0, // 원하는 너비로 설정
                                    child: TextField(
                                      controller: searchController,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.search),
                                        hintText: '찾고 싶은 단체를 검색하세요',
                                        hintStyle: TextStyle(fontSize: 16),
                                        fillColor: Color(0xFFF5F5F5),
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      onChanged: (text) {
                                        _filterList();
                                      },
                                    ),
                                  ),
                                ),
                                if (filtered_organization_list.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        '참여할 수 있는 단체가 없습니다!',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: const Color.fromRGBO(
                                              158, 158, 158, 1),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ...filtered_organization_list.map(
                                    (organization) => Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 10.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 2),
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    organization['org_name']!,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    organization['email'] ?? "",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    organization[
                                                            'description'] ??
                                                        "",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8, // 두 요소 사이의 간격 조정
                                            ),
                                            SizedBox(
                                              width: 80, // 버튼의 고정된 너비 설정
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  bool res =
                                                      await applyParticipation(
                                                          organization[
                                                              'organization_id']);
                                                  if (res) _showMessage();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor:
                                                      Color(0xff495ECA),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.022),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0), // 꼭짓점 반지름 조정
                                                  ),
                                                ),
                                                child: Text('참가 신청',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14)),
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
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
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
            icon: Icon(Icons.access_alarm),
            label: 'Alarms',
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
