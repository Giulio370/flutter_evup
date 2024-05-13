import 'package:evup_flutter/Classi/User.dart';
import 'package:evup_flutter/main.dart';
import 'package:evup_flutter/userInfo.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  String _phonePrefix = '+39';
  bool _conditionAccepted = false;

  void _signup() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      // Form is valid, proceed with signup
      String email = _emailController.text;
      String password = _passwordController.text;
      String firstName = _firstNameController.text;
      String lastName = _lastNameController.text;
      String phoneNumber = _phoneNumberController.text;

      // Send signup request to backend
      try {
        Response response = await Dio().post('http://localhost:8000/auth/signup/email',
            data: {
              'email': email,
              'password': password,
              'firstName': firstName,
              'lastName': lastName,
              'conditionAccepted': _conditionAccepted.toString(),
              'phoneNumber': phoneNumber,
              'phonePrefix': _phonePrefix,
            });

            if(response.statusCode == 200){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            }

        // Handle response as needed
        print(response.data);
      } catch (error) {
        // Handle error
        print('Error during signup: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // You can add more validation if needed
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
                  // You can add more validation if needed
                  return null;
                },
              ),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  // You can add more validation if needed
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  // You can add more validation if needed
                  return null;
                },
              ),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _phonePrefix,
                    onChanged: (String? newValue) {
                      setState(() {
                        _phonePrefix = newValue!;
                      });
                    },
                    items: <String>['+39', '+1', '+44', '+33'] // Add more prefixes as needed
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        // You can add more validation if needed
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              CheckboxListTile(
                title: Text('I accept the terms and conditions'),
                value: _conditionAccepted,
                onChanged: (bool? value) {
                  if(value != null){
                    setState(() {
                      _conditionAccepted = value;
                    });
                  }
                  
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signup,
                child: Text('Signup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// void main() {
//   runApp(MaterialApp(
//     home: SignupPage(),
//   ));
// }
