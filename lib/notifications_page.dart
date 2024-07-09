import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationsTab extends StatefulWidget {
  final user_info;
  NotificationsTab({required this.user_info});

  @override
  _NotificationsTabState createState() =>
      _NotificationsTabState(user_info: user_info);
}

class _NotificationsTabState extends State<NotificationsTab> {
  final user_info;
  _NotificationsTabState({required this.user_info});

  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getNotifications();
  }

  Future<void> getNotifications() async {
    final response = await http.post(
      Uri.parse("https://172.10.7.95/api/get_notifications"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': user_info['user_id'].toString(),
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        notifications = jsonDecode(response.body)['notifications'] ?? [];
        isLoading = false;
      });
      print(notifications);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notifications')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF495ECA),
        automaticallyImplyLeading: false,
        title: Text('알림'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '알림이 없습니다.',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '새로운 알림이 도착하면 여기에서 확인할 수 있습니다.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.notifications),
                        title: Text(notifications[index]['title']),
                        subtitle: Text(notifications[index]['subtitle']),
                      );
                    },
                  ),
                ),
    );
  }
}