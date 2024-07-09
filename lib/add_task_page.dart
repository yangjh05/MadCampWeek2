import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTaskPage extends StatefulWidget {
  final user_info, org_info;
  AddTaskPage({required this.user_info, required this.org_info});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  dynamic subTreeUsers = [];
  String _title = '';
  String _description = '';
  DateTime? _startDate;
  DateTime? _endDate;
  int? selectedUserId;
  bool _isLoadingComplete = false;

  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSubTree();
  }

  Future<void> getSubTree() async {
    final response = await http.post(
      Uri.parse("https://172.10.7.95/api/get_subtree"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': widget.user_info['user_id'].toString(),
        'org_id': widget.org_info['organization_id'].toString(),
      }),
    );

    if (response.statusCode == 200) {
      print("Body");
      print(jsonDecode(response.body));
      setState(() {
        subTreeUsers = jsonDecode(response.body)['subTree'];
        print(subTreeUsers);
        print("Sub Tree");
        print(subTreeUsers);
        _isLoadingComplete = true;
      });
    } else {
      throw Exception('Failed to get subtree');
    }
  }

  Future<void> _addTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final response = await http.post(
        Uri.parse("https://172.10.7.95/api/add_task"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'organization_id': widget.org_info['organization_id'].toString(),
          'root_user_id': widget.user_info['user_id'].toString(),
          'title': _title,
          'description': _description,
          'start_date': _startDate!.toIso8601String(),
          'end_date': _endDate!.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
      } else {
        throw Exception('Failed to add task');
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: isStart ? DateTime(2000) : (_startDate ?? DateTime(2000)),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text = '${_startDate!.toLocal()}'.split(' ')[0];
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
            _endDateController.text = '';
          }
        } else {
          _endDate = picked;
          _endDateController.text = '${_endDate!.toLocal()}'.split(' ')[0];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF495ECA),
          title: Text('업무 추가',
              style: TextStyle(color: Colors.white, fontSize: 20)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  DropdownButton<int>(
                    value: selectedUserId,
                    hint: Text('Select User'),
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedUserId = newValue;
                      });
                    },
                    items: subTreeUsers.map<DropdownMenuItem<int>>((user) {
                      print("user");
                      print(user);
                      return DropdownMenuItem<int>(
                        value: user['user_id'],
                        child: Text(user['username']),
                      );
                    }).toList(),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _title = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _description = value!;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _startDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      hintText: 'Select start date',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select start date';
                      }
                      return null;
                    },
                    onTap: () => _selectDate(context, true),
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    controller: _endDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      hintText: 'Select end date',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select end date';
                      }
                      return null;
                    },
                    onTap: () => _selectDate(context, false),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addTask,
                    child: Text(
                      '추가하기',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF495ECA),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
