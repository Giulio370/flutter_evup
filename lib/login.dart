
import 'package:evup_flutter/Classi/User.dart';
import 'package:evup_flutter/home_page.dart';
import 'package:evup_flutter/signup.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'userInfo.dart'; 



class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Dio _dio = Dio();

  String? _refreshToken;
  String? _accessToken;

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
        options: Options(responseType: ResponseType.json, followRedirects: false),  
        
      );

      if (response.statusCode == 200) {
        // Se il login ha avuto successo, estrai e salva i cookie
        List<String>? cookies = response.headers['set-cookie'];
        if (cookies != null) {
          for (String cookie in cookies) {
            if (cookie.contains('refresh-token')) {
              _refreshToken = cookie.split(';')[0];
            } else if (cookie.contains('access-token')) {
              _accessToken = cookie.split(';')[0];
            }
          }
        }
        if (_refreshToken != null && _accessToken != null) {
          // Ora puoi navigare alla tua pagina successiva dopo il login
          print('accessToken: ${_accessToken}');
          print('refreshToken: ${_refreshToken}');
          
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => LoginSuccessPage(
          //       refreshToken: _refreshToken!,
          //       accessToken: _accessToken!,
          //     ),
          //   ),
          // );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                refreshToken: _refreshToken!,
                accessToken: _accessToken!,
              ),
            ),
          );




        } else {
          // Se manca uno dei due token, gestisci l'errore
          print('Errore: token mancante nella risposta del server');
        }

        User user = User.fromJson(response.data);
        print('Benvenuto, ${user.firstName} ${user.lastName}');
        print('Email: ${user.email}');
        

      } else {
        // Gestisci errori di login qui
        print('Errore durante il login: ${response.statusCode}');
      }
    } catch (e) {
      // Gestisci eccezioni qui
      print('Errore durante la richiesta HTTP: $e');
    }
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
              SizedBox(height: 10),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                ElevatedButton(onPressed: login,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color.fromARGB(255, 126, 0, 148),
                ),
                 child: Text('Login')),
                SizedBox(width: 10),
                ElevatedButton(onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SignupPage() ));
                }, 
                child: Text('Back To SignUp'))
              ],)
              // SizedBox(height: 12.0),
              // ElevatedButton(
              //   onPressed: login,
              //   child: Text('Login'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
