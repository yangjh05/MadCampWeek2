import 'package:flutter/material.dart';

class MyPageTab extends StatelessWidget {
  final user_info;
  MyPageTab({required this.user_info});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("MyPage Tab Content"),
    );
  }
}
