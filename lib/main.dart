import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:madcamp_week2/google_sign_up_page.dart';
import 'home.dart'; // HomeScreen을 정의한 파일
import 'sign_up_page.dart'; // SignUpScreen을 정의한 파일
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId:
  //     '32011394232-g48tj7ct06e8qgp29ck3nt18ph20ahg9.apps.googleusercontent.com',
  scopes: scopes,
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      // 여기서 서버로 로그인 요청을 보내고 응답을 처리합니다.
      print('Username: $username');
      print('Password: $password');

      final response = await http.post(
        Uri.parse('https://172.10.7.95/api/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'userid': username,
          'password': password,
        }),
      );

      print(response.body);

      // 예시: 로그인 성공 시 다른 화면으로 이동
      if (response.statusCode == 200) {
        final user_info = jsonDecode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    user_info: user_info['user'],
                  )),
        );
      } else if (response.statusCode == 401) {
        // 로그인 실패 시 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid username or password')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to login: ${response.body}')),
        );
      }
    }
  }

  void _newUser() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await _googleSignIn.signIn();
      if (_googleSignIn.currentUser != null) {
        // Get the Google token
        final googleAuth = await _googleSignIn.currentUser!.authentication;

        // Send the token to your backend to verify and create a session
        final response = await http.post(
          Uri.parse('https://172.10.7.95/api/google_login'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'token': googleAuth.idToken!,
          }),
        );

        if (response.statusCode == 200) {
          final user_info = jsonDecode(response.body);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(
                      user_info: user_info['user'],
                    )),
          );
        } else if (response.statusCode == 201) {
          final user_info = jsonDecode(response.body);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GoogleSignUpScreen(
                      googleId: user_info['googleId'],
                      email: user_info['email'],
                      username: user_info['name'],
                    )),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Google login failed: ${response.body}')),
          );
        }
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: _newUser,
                    child: Text('Sign Up'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _handleGoogleSignIn,
                child: Container(
                  child: Image.asset(
                    'assets/google_logo.png', // 구글 로고 이미지 경로
                    height: 40.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
