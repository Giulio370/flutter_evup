import 'package:evup_flutter/Classi/User.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class LoginSuccessPage extends StatelessWidget {
  final String refreshToken;
  final String accessToken;

  LoginSuccessPage({required this.refreshToken, required this.accessToken});


  Future<User> fetchUser() async {
    String url1 = 'http://localhost:8000/auth/fetch/user';
    final Dio dio = Dio();

    try {
      // Crea un oggetto Options per includere i cookie nella richiesta
      Options options = Options(
        responseType: ResponseType.json,
        followRedirects: false,
        headers: {'cookie': '$refreshToken; $accessToken'},
      );
      final response = await dio.get(
        url1,
        options: options,
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Errore durante la richiesta HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore durante la richiesta HTTP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagina'),
      ),
      body: FutureBuilder<User>(
        future: fetchUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final User user = snapshot.data!;
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nome: ${user.firstName}'),
                  Text('Cognome: ${user.lastName}'),
                  Text('Email: ${user.email}'),
                  Text('Ruolo: ${user.role}'),
                  Text('Piano: ${user.plan}'),
                  Text('Descrizione: ${user.description}'),
                  Image.network(user.picture),
                ],
              ),
            );
          } else {
            return Center(child: Text('Nessun dato disponibile'));
          }
        },
      ),
    );
  }
}
