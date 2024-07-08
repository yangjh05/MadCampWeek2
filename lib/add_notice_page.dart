import 'package:flutter/material.dart';

class AddNoticePage extends StatefulWidget {
  final Map user_info;
  final Map? org_info;

  AddNoticePage({required this.user_info, this.org_info});

  @override
  _AddNoticePageState createState() => _AddNoticePageState();
}

class _AddNoticePageState extends State<AddNoticePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

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
              onPressed: () {
                // Implement the post submission logic here
                Navigator.of(context).pop();
              },
              child: Text(
                '완료',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
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
                    color: Colors.grey),
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            Divider(color: Colors.grey),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: '내용을 입력하세요.',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
