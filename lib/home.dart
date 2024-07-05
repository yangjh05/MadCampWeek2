import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final user_info;
  HomeScreen({required this.user_info});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [],
        title: Text("Welcome, ${widget.user_info['username']}!"),
      ),
      body: Center(
        child: Text("Yay"),
      ),
    );
  }
}
