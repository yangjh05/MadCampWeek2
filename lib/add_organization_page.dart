import 'package:flutter/material.dart';

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
  final _descriptionController = TextEditingController();
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
                Text('Add a Organization',
                    style: TextStyle(
                        fontSize: 42,
                        color: Color(0xFF495ECA),
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Create a new Organization',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 24),
                TextFormField(
                  controller: _organizationNameController,
                  decoration: _inputDecoration('Organization Name'),
                  style: TextStyle(fontSize: 14),
                  validator: (value) {
                    print(value);
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name of the organization';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 7,
                  decoration: _inputDecoration('Description'),
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate())
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddRolesPage(
                            organizationName: _organizationNameController.text,
                            organizationDesc: _descriptionController.text,
                          ),
                        ),
                      );
                  },
                  child: Text('Next Step',
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
  final organizationName, organizationDesc;
  AddRolesPage(
      {required this.organizationName, required this.organizationDesc});

  @override
  _AddRolesState createState() => _AddRolesState(
      organizationDesc: organizationDesc, organizationName: organizationName);
}

class _AddRolesState extends State<AddRolesPage> {
  final organizationName, organizationDesc;

  List<Role> Roles = [];
  final _formKey = GlobalKey<FormState>();
  _AddRolesState(
      {required this.organizationName, required this.organizationDesc});

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

  @override
  Widget build(BuildContext context) {
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
        body: SingleChildScrollView(
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
        ));
  }
}
