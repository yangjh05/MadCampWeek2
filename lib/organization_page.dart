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
    // TODO: implement initState
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
    // TODO: implement build
    if (!isLoadingComplete) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Center(
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children: [
            ...organization_list.map((organization) => Card(
                  child: Container(
                    height: 70,
                    child: Center(
                      child: Text(organization['org_name']!),
                    ),
                  ),
                )),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddOrganizationPage(
                            user_info: user_info,
                          )),
                );
              },
              child: Text("Add an Organization..."),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: Text("Participate in an Organization..."),
            ),
          ],
        ),
      );
    }
  }
}
