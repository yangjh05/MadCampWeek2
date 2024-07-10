import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddNoticePage extends StatefulWidget {
  final Map user_info;
  final Map org_info;

  AddNoticePage({required this.user_info, required this.org_info});

  @override
  _AddNoticePageState createState() => _AddNoticePageState();
}

class _AddNoticePageState extends State<AddNoticePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _sendNotice() async {
    final String title = _titleController.text;
    final String content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목과 내용을 모두 입력하세요.')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse("https://172.10.7.95/api/send_notices"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'organization_id': widget.org_info['organization_id'].toString(),
        'user_id': widget.user_info['user_id'].toString(),
        'title': title,
        'content': content,
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send notice')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text('공지사항 작성', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFF495ECA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0), // 내부 패딩 추가
              ),
              onPressed: _sendNotice,
              child: Text(
                '완료',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '제목',
                hintStyle: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.grey),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: '내용을 입력하세요.',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              maxLines: null,
              minLines: 10,
              keyboardType: TextInputType.multiline,
              expands: false,
            ),
          ],
        ),
      ),
    );
  }
}
