import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'home.dart';

class AddOrganizationPage extends StatefulWidget {
  final user_info;
  AddOrganizationPage({required this.user_info});

  @override
  _AddOrganizationState createState() =>
      _AddOrganizationState(user_info: user_info);
}

class _AddOrganizationState extends State<AddOrganizationPage> {
  final user_info;
  final _organizationNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rootRoleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  _AddOrganizationState({required this.user_info});

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

  void _navigateToAddRolesPage() {
    if (_formKey.currentState!.validate()) {
      Role rootRole = Role(
        _rootRoleController.text,
        '', // Root role does not have a parent role
        'Root Role', // You can adjust this description as needed
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddRolesPage(
            organizationName: _organizationNameController.text,
            organizationEmail: _emailController.text,
            organizationDesc: _descriptionController.text,
            organizationRoot: _rootRoleController.text,
            user_info: user_info,
            initialRoles: [rootRole], // Pass the root role as initial role
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
                Text('조직 추가하기',
                    style: TextStyle(
                        fontSize: 42,
                        color: Color(0xFF495ECA),
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('새로운 조직을 만들어보세요', style: TextStyle(fontSize: 16)),
                SizedBox(height: 24),
                TextFormField(
                  controller: _organizationNameController,
                  decoration: _inputDecoration('조직 이름'),
                  style: TextStyle(fontSize: 14),
                  validator: (value) {
                    print(value);
                    if (value == null || value.isEmpty) {
                      return '조직의 이름을 입력해주세요';
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
                  decoration: _inputDecoration('조직 설명'),
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _rootRoleController,
                  decoration: _inputDecoration('내 직급'),
                  style: TextStyle(fontSize: 14),
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
  String parent_name;
  String description;

  Role(this.name, this.parent_name, this.description);
}

class AddRolesPage extends StatefulWidget {
  final String organizationName;
  final String organizationEmail;
  final String organizationDesc;
  final String organizationRoot;
  final dynamic user_info;
  final List<Role> initialRoles;

  AddRolesPage({
    required this.organizationName,
    required this.organizationEmail,
    required this.organizationDesc,
    required this.organizationRoot,
    required this.user_info,
    required this.initialRoles,
  });

  @override
  _AddRolesState createState() => _AddRolesState(
      organizationDesc: organizationDesc,
      organizationEmail: organizationEmail,
      organizationName: organizationName,
      organizationRoot: organizationRoot,
      user_info: user_info,
      initialRoles: initialRoles);
}

class _AddRolesState extends State<AddRolesPage> {
  final String organizationName;
  final String organizationEmail;
  final String organizationDesc;
  final String organizationRoot;
  final dynamic user_info;
  final List<Role> initialRoles;

  List<Role> Roles = [];
  final _formKey = GlobalKey<FormState>();

  _AddRolesState({
    required this.organizationName,
    required this.organizationEmail,
    required this.organizationDesc,
    required this.organizationRoot,
    required this.user_info,
    required this.initialRoles,
  });

  @override
  void initState() {
    super.initState();
    Roles = List.from(initialRoles); // Initialize Roles with initial roles
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
          title: Text('Add Role'),
          content: Form(
            key: _dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter role name',
                  ),
                  validator: (value) {
                    print(Roles);
                    if (value == null || value.isEmpty)
                      return 'Please enter the name';
                    else {
                      Role? role = Roles.firstWhere(
                        (role) => role.name == value,
                        orElse: () => Role('', '', ''),
                      );
                      if (!(role.name == '' &&
                          role.parent_name == '' &&
                          role.description == ''))
                        return 'This role exists already.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: parentNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter parent role name',
                  ),
                  validator: (value) {
                    if ((value != null && value.isNotEmpty)) {
                      Role? role = Roles.firstWhere(
                        (role) => role.name == value,
                        orElse: () => Role('', '', ''),
                      );
                      if ((role.name == '' &&
                          role.parent_name == '' &&
                          role.description == ''))
                        return "Pick a valid parent.";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Enter description',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
                child: Text('Save'),
                onPressed: () {
                  if (_dialogFormKey.currentState!.validate()) {
                    setState(() {
                      Roles.add(Role(
                        nameController.text,
                        parentNameController.text,
                        descriptionController.text,
                      ));
                    });
                    Navigator.of(context).pop();
                  }
                }),
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
        SnackBar(content: Text('Failed to add organization: ${response.body}')),
      );
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
                  Text('Add a Organization',
                      style: TextStyle(
                          fontSize: 42,
                          color: Color(0xFF495ECA),
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Create new Roles.', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 24),
                  ElevatedButton(
                      onPressed: _addRoleData, child: Text("Add a Role..")),
                  SizedBox(height: 16),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.6,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: Roles.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: ExpansionTile(
                                  title: Text(Roles[index].name),
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(Roles[index].parent_name),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(Roles[index].description),
                                    ),
                                  ],
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
