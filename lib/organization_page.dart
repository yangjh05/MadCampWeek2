import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:madcamp_week2/add_organization_page.dart';

class OrganizationTab extends StatefulWidget {
  final user_info;
  OrganizationTab({required this.user_info});

  @override
  _OrganizationTabState createState() =>
      _OrganizationTabState(user_info: user_info);
}

class _OrganizationTabState extends State<OrganizationTab> {
  final user_info;
  dynamic organization_list;
  bool orgExists = true;
  bool isLoadingComplete = false;
  _OrganizationTabState({required this.user_info});

  @override
  void initState() {
    super.initState();
    getOrganizationList();
  }

  void getOrganizationList() async {
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
        isLoadingComplete = true;
        print(response.body);
        final org_info = jsonDecode(response.body);
        organization_list = org_info['organizations'];
      });
      print(organization_list);
    } else if (response.statusCode == 201) {
      setState(() {
        organization_list = [];
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

  @override
  Widget build(BuildContext context) {
    if (!isLoadingComplete) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(20.0),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                child: Text(
                  '내 단체',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (organization_list.isEmpty)
                Center(
                  child: Text(
                    '참여한 단체가 없습니다.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                ...organization_list.map((organization) => Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
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
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    organization['org_name']!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    organization['email'] ?? "",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'PlusJakartaSans',
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    organization['description'] ?? "",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    )),
              SizedBox(height: 50),
            ],
          ),
          Positioned(
            bottom: 80.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddOrganizationPage(
                            user_info: user_info,
                          )),
                );
              },
              child: Icon(Icons.add, color: Colors.black),
              backgroundColor: Color(0xfff9e2af),
            ),
          ),
        ],
      );
    }
  }
}
