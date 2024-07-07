// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'home.dart';

class AddOrganizationPage extends StatefulWidget {
  final user_info, org_info;
  AddOrganizationPage({required this.user_info, required this.org_info});

  @override
  _AddOrganizationState createState() =>
      _AddOrganizationState(user_info: user_info, org_info: org_info);
}

class _AddOrganizationState extends State<AddOrganizationPage> {
  final user_info, org_info;
  _AddOrganizationState({required this.user_info, required this.org_info});

  final _organizationNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rootRoleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (org_info != null) {
      _organizationNameController.text = org_info['org_name'];
      _emailController.text = org_info['email'];
      _descriptionController.text = org_info['description'];
    }
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: Colors.grey,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: Color(0xFF495ECA),
        ),
      ),
      labelStyle: TextStyle(fontSize: 14),
    );
  }

  void _navigateToAddRolesPage() async {
    if (_formKey.currentState!.validate()) {
      List<Role> Roles = [];
      if (org_info == null) {
        Role rootRole = Role(
            _rootRoleController.text,
            '', // Root role does not have a parent role
            'Root Role',
            -1 // You can adjust this description as needed
            );
        Roles = [rootRole];
      } else {
        final response = await http.post(
            Uri.parse('https://172.10.7.95/api/find_all_relationship'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'org_id': org_info['organization_id'].toString(),
            }));
        if (response.statusCode == 200) {
          final rel_info = jsonDecode(response.body);
          //print(rel_info['res'][0]);
          for (dynamic e in rel_info['res']) {
            print(e);
            Role tmp = Role(
                e['role_name'],
                e['parent_organization_roles'] == null
                    ? null
                    : e['parent_organization_roles'],
                e['description'],
                e['organization_role_id']);
            Roles.add(tmp);
          }
          print(Roles);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to get response: ${response.body}')),
          );
          throw Exception();
        }
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddRolesPage(
            organizationName: _organizationNameController.text,
            organizationEmail: _emailController.text,
            organizationDesc: _descriptionController.text,
            organizationRoot: org_info == null ? _rootRoleController.text : '',
            user_info: user_info,
            org_info: org_info,
            initialRoles: Roles, // Pass the root role as initial role
          ),
        ),
      );
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                org_info == null
                    ? Text('단체 추가하기',
                        style: TextStyle(
                            fontSize: 42,
                            color: Color(0xFF495ECA),
                            fontWeight: FontWeight.bold))
                    : Text('단체 수정하기',
                        style: TextStyle(
                            fontSize: 42,
                            color: Color(0xFF495ECA),
                            fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                org_info == null
                    ? Text('새로운 단체를 만들어보세요', style: TextStyle(fontSize: 16))
                    : Text('단체 정보를 수정합니다.', style: TextStyle(fontSize: 16)),
                SizedBox(height: 24),
                TextFormField(
                  controller: _organizationNameController,
                  decoration: _inputDecoration('단체 이름'),
                  style: TextStyle(fontSize: 14),
                  validator: (value) {
                    print(value);
                    if (value == null || value.isEmpty) {
                      return '단체의 이름을 입력해주세요';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration('이메일'),
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 7,
                  decoration: _inputDecoration('단체 설명'),
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  height: 10,
                ),
                if (org_info == null)
                  TextFormField(
                    controller: _rootRoleController,
                    decoration: _inputDecoration('내 직급'),
                    style: TextStyle(fontSize: 14),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return '역할 이름은 빈칸일 수 없습니다.';
                      return null;
                    },
                  ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: _navigateToAddRolesPage,
                  child: Text('다음 단계',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF495ECA),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Role {
  String name;
  String? parent_name;
  String? description;
  int role_id;

  Role(this.name, this.parent_name, this.description, this.role_id);
}

class AddRolesPage extends StatefulWidget {
  final String organizationName;
  final String organizationEmail;
  final String organizationDesc;
  final String organizationRoot;
  final dynamic user_info, org_info;
  final List<Role> initialRoles;

  AddRolesPage({
    required this.organizationName,
    required this.organizationEmail,
    required this.organizationDesc,
    required this.organizationRoot,
    required this.user_info,
    required this.org_info,
    required this.initialRoles,
  });

  @override
  _AddRolesState createState() => _AddRolesState(
      organizationDesc: organizationDesc,
      organizationEmail: organizationEmail,
      organizationName: organizationName,
      organizationRoot: organizationRoot,
      user_info: user_info,
      org_info: org_info,
      initialRoles: initialRoles);
}

class _AddRolesState extends State<AddRolesPage> {
  final String organizationName;
  final String organizationEmail;
  final String organizationDesc;
  final String organizationRoot;
  final dynamic user_info, org_info;
  final List<Role> initialRoles;

  List<Role> Roles = [];
  final _formKey = GlobalKey<FormState>();

  _AddRolesState({
    required this.organizationName,
    required this.organizationEmail,
    required this.organizationDesc,
    required this.organizationRoot,
    required this.user_info,
    required this.org_info,
    required this.initialRoles,
  });

  @override
  void initState() {
    super.initState();
    Roles = List.from(initialRoles); // Initialize Roles with initial roles
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey, fontSize: 14), // 힌트 텍스트 크기 조정
      floatingLabelBehavior: FloatingLabelBehavior.never,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: Colors.grey,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: Color(0xFF495ECA),
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
          vertical: 6.0, horizontal: 12.0), // 패딩을 줄여서 텍스트 박스 크기 줄이기
      filled: true,
      fillColor: Colors.white,
    );
  }

  int find_parent(List<int> parent, int x) {
    return parent[x] != x ? find_parent(parent, parent[x]) : x;
  }

  List<int> union_parent(List<int> parent, int a, int b) {
    a = find_parent(parent, a);
    b = find_parent(parent, b);
    if (a < b)
      parent[b] = a;
    else
      parent[a] = b;
    return parent;
  }

  bool _hasCycle(int edited, String new_child, String? new_parent) {
    Map<String, int> nameToNum = {};
    int node_num = 0;
    int i = 0;
    List<int> parent = List.filled(999, 0);
    if (edited == -1 && new_child == "") return true;
    for (var e in Roles) {
      print(e);
      if (!nameToNum.containsKey(e.name)) nameToNum[e.name] = node_num++;
      if (i != edited) {
        if (e.parent_name != null && !nameToNum.containsKey(e.parent_name))
          nameToNum[e.parent_name!] = node_num++;
      } else {
        if (new_parent != null && !nameToNum.containsKey(new_parent))
          nameToNum[new_parent] = node_num++;
      }
      i++;
    }
    if (edited == -1) {
      if (!nameToNum.containsKey(new_child)) nameToNum[new_child] = node_num++;
      if (new_parent != null && !nameToNum.containsKey(new_parent))
        // ignore: curly_braces_in_flow_control_structures
        nameToNum[new_parent] = node_num++;
    }
    for (var j = 0; j < node_num; j++) parent[j] = j;
    i = 0;
    for (var e in Roles) {
      if (e.parent_name != null && i != edited) {
        if (find_parent(parent, nameToNum[e.name]!) ==
            find_parent(parent, nameToNum[e.parent_name]!)) return true;
        union_parent(parent, nameToNum[e.name]!, nameToNum[e.parent_name]!);
      } else if (new_parent != null && i == edited) {
        if (find_parent(parent, nameToNum[e.name]!) ==
            find_parent(parent, nameToNum[new_parent]!)) return true;
        union_parent(parent, nameToNum[e.name]!, nameToNum[new_parent]!);
      }
      i++;
    }

    return false;
  }

  void _addRoleData() {
    final _dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController nameController = TextEditingController();
        final TextEditingController parentNameController =
            TextEditingController();
        final TextEditingController descriptionController =
            TextEditingController();

        return AlertDialog(
          title: Text(
            '새 역할 추가하기..',
            style: TextStyle(fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _dialogFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: nameController,
                    style: TextStyle(fontSize: 14), // 입력 텍스트 크기 조정
                    decoration: _inputDecoration('역할 이름을 입력하세요..'),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return '역할 이름은 빈칸일 수 없습니다.';
                      else {
                        Role? role = Roles.firstWhere(
                          (role) => role.name == value,
                          orElse: () => Role('', '', '', -1),
                        );
                        if (!(role.name == '' &&
                            role.parent_name == '' &&
                            role.description == '')) return '그 역할은 이미 존재합니다.';
                        if (_hasCycle(-1, nameController.text, value))
                          return '역할은 순환적 관계를 이룰 수 없습니다.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 6),
                  TextFormField(
                    controller: parentNameController,
                    style: TextStyle(fontSize: 14), // 입력 텍스트 크기 조정
                    decoration: _inputDecoration('직속 부모 역할 이름을 입력하세요..'),
                    validator: (value) {
                      if ((value != null && value.isNotEmpty)) {
                        Role? role = Roles.firstWhere(
                          (role) => role.name == value,
                          orElse: () => Role('', '', '', -1),
                        );
                        if ((role.name == '' &&
                            role.parent_name == '' &&
                            role.description == '')) return '유효한 역할을 선택하십시오.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 6),
                  TextFormField(
                    controller: descriptionController,
                    style: TextStyle(fontSize: 14), // 입력 텍스트 크기 조정
                    decoration: _inputDecoration('역할 설명을 입력하세요..'),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소', style: TextStyle(fontSize: 14)),
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF495ECA),
                side: BorderSide(color: Color(0xFF495ECA)), // 테두리 색상
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0), // 모서리 둥글기
                ),
                padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                minimumSize: Size(32, 18),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('추가', style: TextStyle(fontSize: 14)),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color.fromARGB(255, 61, 89, 227),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0), // 모서리 둥글기
                ),
                padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                minimumSize: Size(32, 18), // 최소 크기
              ),
              onPressed: () {
                if (_dialogFormKey.currentState!.validate()) {
                  setState(() {
                    Roles.add(Role(
                        nameController.text,
                        parentNameController.text,
                        descriptionController.text,
                        -1));
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editRoleData(int index) {
    final _dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController nameController =
            TextEditingController(text: Roles[index].name);
        final TextEditingController parentNameController =
            TextEditingController(text: Roles[index].parent_name);
        final TextEditingController descriptionController =
            TextEditingController(text: Roles[index].description);

        return AlertDialog(
          title: Text(
            '역할 수정..',
            style: TextStyle(fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _dialogFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: nameController,
                    style: TextStyle(fontSize: 14), // 입력 텍스트 크기 조정
                    decoration: _inputDecoration('역할 이름을 입력하세요..'),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return '역할 이름은 빈칸일 수 없습니다.';
                      else {
                        if (Roles.where((role) => role.name == value).length >
                                0 &&
                            Roles[index].name != value) {
                          return '그 역할은 이미 존재합니다.';
                        }
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 6),
                  TextFormField(
                    controller: parentNameController,
                    style: TextStyle(fontSize: 14), // 입력 텍스트 크기 조정
                    decoration: _inputDecoration('직속 부모 역할 이름을 입력하세요..'),
                    validator: (value) {
                      if ((value != null && value.isNotEmpty)) {
                        if (!(Roles.where((role) => role.name == value).length >
                                    0 &&
                                nameController.text != value) ||
                            value == Roles[index].name)
                          return '유효한 역할을 선택하십시오.';
                        if (_hasCycle(index, "", value))
                          return '역할은 순환적 관계를 이룰 수 없습니다.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 6),
                  TextFormField(
                    controller: descriptionController,
                    style: TextStyle(fontSize: 14), // 입력 텍스트 크기 조정
                    decoration: _inputDecoration('역할 설명을 입력하세요..'),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소', style: TextStyle(fontSize: 14)),
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF495ECA),
                side: BorderSide(color: Color(0xFF495ECA)), // 테두리 색상
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0), // 모서리 둥글기
                ),
                padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                minimumSize: Size(32, 18),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('추가', style: TextStyle(fontSize: 14)),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color.fromARGB(255, 61, 89, 227),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0), // 모서리 둥글기
                ),
                padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                minimumSize: Size(32, 18), // 최소 크기
              ),
              onPressed: () {
                if (_dialogFormKey.currentState!.validate()) {
                  setState(() {
                    for (int i = 0; i < Roles.length; i++) {
                      if (Roles[i].parent_name == Roles[index].name)
                        Roles[i].parent_name = nameController.text;
                    }
                    Roles[index] = Role(
                        nameController.text,
                        parentNameController.text,
                        descriptionController.text,
                        Roles[index].role_id);
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRoles() async {
    print(
        'Submitting roles: $organizationName, $organizationEmail, $organizationDesc, $organizationRoot, $Roles');
    // 서버로 보내기
    // organization_name, root_name, description, parent_name, roles, userinfo 다 보내기
    print(Roles.map((role) => {role.name, role.parent_name, role.description}));
    if (org_info == null) {
      final response = await http.post(
        Uri.parse('https://172.10.7.95/api/add_organization'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'org_name': organizationName,
          'desc': organizationDesc,
          'email': organizationEmail,
          'Roles': Roles.map((role) => {
                'name': role.name,
                'parent_name': role.parent_name,
                'description': role.description,
              }).toList(),
          'user_info': user_info,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Add organization successful')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(user_info: user_info)),
        );
      } else {
        print('Failed to add organization: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add organization: ${response.body}')),
        );
      }
    } else {
      final response = await http.post(
        Uri.parse('https://172.10.7.95/api/edit_relationship'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'orga_id': org_info['organization_id'],
          'org_name': organizationName,
          'desc': organizationDesc,
          'email': organizationEmail,
          'Roles': Roles.map((role) => {
                'name': role.name,
                'parent_name': role.parent_name,
                'description': role.description,
                'org_role_id': role.role_id
              }).toList(),
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Editing organization successful')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(user_info: user_info)),
        );
      } else {
        print('Failed to edit organization: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add organization: ${response.body}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.black),
            onPressed: _submitRoles,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white, // body 부분의 배경색을 흰색으로 설정
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('역할 추가',
                      style: TextStyle(
                          fontSize: 42,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('단체 내 다양한 역할들을 추가하세요',
                      style: TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(125, 125, 125, 0.973),
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _addRoleData,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromARGB(255, 61, 89, 227),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0), // 모서리 둥글기
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 12.0, // 패딩 조정
                        horizontal: 16.0,
                      ),
                      minimumSize: Size(100, 40), // 최소 크기 조정
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 20.0), // 아이콘 크기 조정
                        SizedBox(width: 8.0), // 아이콘과 텍스트 간의 간격
                        Text(
                          "새 역할 추가..",
                          style: TextStyle(fontSize: 16.0), // 텍스트 크기 조정
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        "추가될 역할 리스트",
                        style: TextStyle(fontSize: 18.0), // 텍스트 크기 조정
                      )),
                  SizedBox(height: 16),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                        //border: Border.all(color: Colors.grey),
                        ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: Roles.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  _editRoleData(index);
                                },
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 12),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8),
                                        Text("역할 이름: " + Roles[index].name),
                                        SizedBox(height: 8),
                                        Text(
                                            "직속 상위 역할 이름: ${Roles[index].parent_name}"),
                                        SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
