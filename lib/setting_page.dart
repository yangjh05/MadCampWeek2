import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
  final user_info;
  SettingsTab({required this.user_info});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Setting Tab Content"),
    );
  }
}
