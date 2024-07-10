import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
        notifications = jsonDecode(response.body)['res'][0] ?? [];
        notifications = notifications.map((notification) {
          return {
            ...notification,
            'date': DateTime.parse(notification['date']),
          };
        }).toList();
        notifications.sort((a, b) => b['date'].compareTo(a['date']));
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

  void _showNotificationDetails(
      BuildContext context, Map<dynamic, dynamic> notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification['title']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  '일시: ${DateFormat('yyyy-MM-dd – kk:mm').format(notification['date'])}'),
              SizedBox(height: 8.0),
              Text('Description: ${notification['description']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                      var notification = notifications[index];
                      return GestureDetector(
                        onTap: () {
                          _showNotificationDetails(context, notification);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.notifications),
                                      SizedBox(width: 8.0),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notification['title'],
                                            style: TextStyle(
                                              color:
                                                  notification['notice_type'] ==
                                                          0
                                                      ? Colors.red
                                                      : Colors.green,
                                            ),
                                          ),
                                          Text(DateFormat('yyyy-MM-dd – kk:mm')
                                              .format(notification['date'])),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    constraints: BoxConstraints(
                                        maxWidth: 150), // 최대 너비 설정
                                    child: Text(
                                      notification['description'],
                                      overflow: TextOverflow
                                          .ellipsis, // 텍스트가 길 경우 말줄임표 표시
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
