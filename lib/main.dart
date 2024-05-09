import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'userInfo.dart'; 

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Dio _dio = Dio();

  Future<void> login() async {
    final String url = 'http://localhost:8000/auth/login/email';
    final Map<String, dynamic> data = {
      'email': _emailController.text,
      'password': _passwordController.text,
    };

    try {
      final response = await _dio.post(
        url,
        data: data,
        options: Options(responseType: ResponseType.json),  
        
      );

      if (response.statusCode == 200) {
        // Gestisci la risposta del backend qui
        // Esempio:
        // final responseData = response.data;
        navigateToOtherPage();  

      } else {
        // Gestisci errori di login qui
        print('Errore durante il login: ${response.statusCode}');
      }
    } catch (e) {
      // Gestisci eccezioni qui
      print('Errore durante la richiesta HTTP: $e');
    }
  }

  void navigateToOtherPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginSuccessPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Container(
          width: 300.0,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 12.0),
              ElevatedButton(
                onPressed: login,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
