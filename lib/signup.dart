import 'package:evup_flutter/login.dart';
import 'package:evup_flutter/main.dart';
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

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));

            // if(response.statusCode == 200){
            //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            // }

        // Handle response as needed
        print(response.data);
      } catch (error) {
        // Handle error
        print('Error during signup: $error');
      }
    }
  }

  ///Questa funzione data un stringa, controlla che essa sia lunga almeno 8 caratteri, contenga una lettera maiuscola,
  ///una minuscola ed un segno
  bool validatePassword(String value){
    bool goodPassword= true;
    if(value.length <8 || !RegExp(r'[A-Z]').hasMatch(value) || !RegExp(r'[a-z]').hasMatch(value) || !RegExp(r'\d').hasMatch(value)|| !RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value) ){
      goodPassword= false;
    }
    return goodPassword;
  }

  ///Questo metodo ritorna un messaggio di errore in base alla composizione della password
  String? errorMessagePassword(String value) {
    // Verifica che la lunghezza della password sia almeno 8 caratteri
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Verifica che la password contenga almeno una lettera maiuscola
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Verifica che la password contenga almeno una lettera minuscola
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    // Verifica che la password contenga almeno un numero
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one digit';
    }

    // Verifica che la password contenga almeno un segno
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    // La password soddisfa tutti i requisiti
    return null;
  } 
 





  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Signup'),
    ),
    body: Center(
      child: Container(
        padding: EdgeInsets.all(20.0),
        constraints: BoxConstraints(maxWidth: 400), // Imposta larghezza massima
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true, // Per consentire al ListView di adattarsi al contenuto
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
                  if(!validatePassword(value)){
                    return errorMessagePassword(value);
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
              // Altri campi del form
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color.fromARGB(255, 126, 0, 148),
                ),
                child: Text('SignUp'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Text('Go to Login'),
              ),
            ],
          ),
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
