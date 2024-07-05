import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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
  //     '975071060042-06pc5s1lpt88flkoe5no2j1hsnm7nc88.apps.googleusercontent.com',
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
        final user_info = jsonDecode(response.body);
        print(response.body);
        print(response.statusCode);

        if (response.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(
                      user_info: user_info['user'],
                    )),
          );
        } else if (response.statusCode == 201) {
          final response = await http.post(
            Uri.parse('https://172.10.7.95/api/signup'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'userid': user_info['email'],
              'password': user_info['googleId'],
              'name': user_info['username'],
              'googleId': user_info['googleId'],
              'email': user_info['email'],
            }),
          );

          final googleAuth = await _googleSignIn.currentUser!.authentication;

          // Send the token to your backend to verify and create a session
          final new_response = await http.post(
            Uri.parse('https://172.10.7.95/api/google_login'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'token': googleAuth.idToken!,
            }),
          );
          final new_user_info = jsonDecode(response.body);
          if (new_response.statusCode == 200) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(
                        user_info: new_user_info['user'],
                      )),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Second Google login failed: ${new_response.body}')),
            );
          }
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

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Spacer(flex: 2),
                Image.asset(
                  'assets/logo.png',
                  width: MediaQuery.of(context).size.width * 0.77,
                  height: MediaQuery.of(context).size.width * 0.77,
                ),
                Spacer(flex: 1),
                Container(
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your ID',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: MediaQuery.of(context).size.height * 0.02),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.012),
                Container(
                  child: TextFormField(
                      obscureText: _obscureText,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical:
                                MediaQuery.of(context).size.height * 0.02),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      }),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        // 여기에 Forgot Password? 클릭 이벤트 추가
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 15),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.022),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // 꼭짓점 반지름 조정
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(color: Colors.grey),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Or login with',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                GestureDetector(
                  onTap: _handleGoogleSignIn,
                  child: Container(
                    child: Image.asset(
                      'assets/google_logo.png', // 구글 로고 이미지 경로
                      height: 50.0,
                    ),
                  ),
                ),
                Spacer(flex: 2),
                GestureDetector(
                  onTap: _newUser,
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Register Now',
                          style: TextStyle(color: Colors.teal, fontSize: 16),
                        ),
                      ],
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


  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //         //title: Text('Login'),
  //         ),
  //     body: Padding(
  //       padding: EdgeInsets.all(16.0),
  //       child: Form(
  //         key: _formKey,
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: <Widget>[
  //             TextFormField(
  //               controller: _usernameController,
  //               decoration: InputDecoration(labelText: 'Username'),
  //               validator: (value) {
  //                 if (value == null || value.isEmpty) {
  //                   return 'Please enter your username';
  //                 }
  //                 return null;
  //               },
  //             ),
  //             TextFormField(
  //               controller: _passwordController,
  //               decoration: InputDecoration(labelText: 'Password'),
  //               obscureText: true,
  //               validator: (value) {
  //                 if (value == null || value.isEmpty) {
  //                   return 'Please enter your password';
  //                 }
  //                 return null;
  //               },
  //             ),
  //             SizedBox(height: 20),
  //             Row(
  //               children: [
  //                 ElevatedButton(
  //                   onPressed: _login,
  //                   child: Text('Login'),
  //                 ),
  //                 SizedBox(
  //                   width: 10,
  //                 ),
  //                 ElevatedButton(
  //                   onPressed: _newUser,
  //                   child: Text('Sign Up'),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 20),
  //             GestureDetector(
  //               onTap: _handleGoogleSignIn,
  //               child: Container(
  //                 child: Image.asset(
  //                   'assets/google_logo.png', // 구글 로고 이미지 경로
  //                   height: 40.0,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
